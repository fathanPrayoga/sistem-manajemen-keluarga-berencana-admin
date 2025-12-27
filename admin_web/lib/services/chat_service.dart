import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Ambil daftar User yang pernah chat (Inbox List)
  Stream<List<Map<String, dynamic>>> getChatUsers() {
    // Asumsi: Kita punya collection 'users' yang punya field 'lastMessageTime'
    // atau kita query collection 'chats' (tergantung struktur DB Mobile App-nya).
    // Skenario umum: Collection 'chats' document ID-nya adalah UID User.
    return _firestore
        .collection('konsultasi')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'uid': doc.id,
              'displayName': data['userName'] ?? 'User Tanpa Nama',
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime': (data['lastMessageTime'] as Timestamp?)
                  ?.toDate(),
              'unreadCount':
                  data['unreadCountAdmin'] ?? 0, // Penting buat badge
            };
          }).toList();
        });
  }

  // 2. Ambil isi chat specific user (Chat Room)
  Stream<List<ChatMessage>> getMessages(String userId) {
    return _firestore
        .collection('konsultasi')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();
        });
  }

  // 3. Kirim Pesan (Admin -> User)
  Future<void> sendMessage(
    String userId,
    String text, {
    String? imageUrl,
  }) async {
    final messageData = {
      'senderId': 'admin', // Hardcode atau ambil dari AuthUser
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Add to subcollection
    await _firestore
        .collection('konsultasi')
        .doc(userId)
        .collection('messages')
        .add(messageData);

    // Update summary di dokumen parent (untuk Inbox List)
    await _firestore.collection('konsultasi').doc(userId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCountUser': FieldValue.increment(1), // Nambah badge di sisi user
    });
  }
}
