import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
        // Order by lastMessageTime if exists, otherwise Firestore will treat missing fields as null
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Parse last message time (supports Timestamp, DateTime, or ISO string)
        final dynamic lastRaw = data['lastMessageTime'] ?? data['lastUpdated'];
        DateTime? lastMessageTime;
        if (lastRaw is Timestamp) {
          lastMessageTime = lastRaw.toDate();
        } else if (lastRaw is DateTime) {
          lastMessageTime = lastRaw;
        } else if (lastRaw is String) {
          lastMessageTime = DateTime.tryParse(lastRaw);
        }

        // Normalize unread count (support int or numeric string, or null)
        final dynamic rawUnread =
            data['unreadCountAdmin'] ?? data['unreadCount'] ?? 0;
        int unreadCount = 0;
        if (rawUnread is int) {
          unreadCount = rawUnread;
        } else if (rawUnread is String) {
          unreadCount = int.tryParse(rawUnread) ?? 0;
        }

        return {
          'uid': doc.id,
          'displayName':
              data['userName'] ?? data['displayName'] ?? 'User Tanpa Nama',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': lastMessageTime,
          'unreadCount': unreadCount, // Penting buat badge
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

  // 2b. Mark all messages as read for admin (reset unread counter)
  Future<void> markAsReadForAdmin(String userId) async {
    try {
      await _firestore.collection('konsultasi').doc(userId).update({
        'unreadCountAdmin': 0,
      });
    } catch (e) {
      // ignore errors if doc missing or other issues
      debugPrint('Error marking as read: $e');
    }
  }

  /// Send message as admin to a user (adds message and updates parent meta)
  Future<void> sendMessage(String userId, String text,
      {String? imageUrl}) async {
    final messageData = {
      'senderId': 'admin',
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
