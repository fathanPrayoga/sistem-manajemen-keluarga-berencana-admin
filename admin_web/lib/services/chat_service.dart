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

        // Safe timestamp parsing
        final dynamic lastRaw = data['lastUpdated'];
        DateTime? lastMessageTime;
        if (lastRaw is Timestamp) {
          lastMessageTime = lastRaw.toDate();
        } else if (lastRaw is DateTime) {
          lastMessageTime = lastRaw;
        }

        return {
          'id': doc
              .id, // User ID (doc name in 'chats' collection is usually userId)
          'chatPath': doc.reference.path,
          'displayName': data['userName'] ?? 'User Tanpa Nama',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': lastMessageTime,
          'unreadCount': data['unreadCountAdmin'] ?? 0,
          'isReadByAdmin':
              data['isReadByAdmin'] ?? true, // Fallback for old data
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

  // 3. Mark all messages as read for admin (reset unreadCounterAdmin)
  Future<void> markAsReadForAdmin(String chatPath) async {
    try {
      await _firestore.doc(chatPath).update({
        'unreadCountAdmin': 0,
        'lastReadTimestampAdmin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore
    }
  }

  // 4. Kirim Pesan (Admin -> User)
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
      'unreadCountUser': FieldValue.increment(1), // Counter unread di sisi user
    });

    // 5. [NEW] Trigger Notification for User
    try {
      final pathSegments = chatPath.split('/');
      // Structure: konsultasi/{categoryId}/chats/{userId}
      if (pathSegments.length >= 4) {
        final userId = pathSegments.last;
        // final categoryId = pathSegments[1];

        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Admin',
          'body': text,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'konsultasi_reply',
          'chatPath': chatPath,
        });
      }
    } catch (e) {
      // Ignore notification errors to not block message sending
      print('Error sending notification: $e');
    }
  }
}
