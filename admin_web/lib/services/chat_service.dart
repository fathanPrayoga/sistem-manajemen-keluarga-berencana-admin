import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Ambil daftar User yang pernah chat (Inbox List)
  // Menggunakan collectionGroup karena chat tersebar di sub-collection category
  Stream<List<Map<String, dynamic>>> getChatUsers() {
    return _firestore
        .collectionGroup('chats')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id, // User ID
          'chatPath':
              doc.reference.path, // Full path doc: konsultasi/{cat}/chats/{uid}
          'displayName': data['userName'] ?? 'User Tanpa Nama',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': (data['lastUpdated'] as Timestamp?)?.toDate(),
          'isReadByAdmin': data['isReadByAdmin'] ?? true,
          // Mobile app uses 'isReadByAdmin' boolean, not a counter
        };
      }).toList();
    });
  }

  // 2. Ambil isi chat specific user (Chat Room)
  // Menerima full path dokumen chat (konsultasi/{cat}/chats/{uid})
  Stream<List<ChatMessage>> getMessages(String chatPath) {
    return _firestore
        .doc(chatPath)
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
    String chatPath,
    String text, {
    String? imageUrl,
  }) async {
    final messageData = {
      'senderId': 'admin',
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Untuk sisi User (jika user support read receipt)
    };

    final chatDocRef = _firestore.doc(chatPath);

    // Add to subcollection messages
    await chatDocRef.collection('messages').add(messageData);

    // Update summary di dokumen parent
    // Note: Mobile app expects 'lastUpdated' field
    await chatDocRef.update({
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
      'isReadByAdmin': true, // Kita yang kirim, jadi sudah terbaca
      'lastSenderId': 'admin',
      // Jika butuh counter unread di sisi user, tambahkan di sini sesuai logic App
      // 'unreadCountUser': FieldValue.increment(1),
    });
  }
}
