import 'package:flutter/material.dart';
import '../../../models/chat_model.dart';
import '../../../services/chat_service.dart';

class ChatRoomViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final String userId; // Lawan bicara

  ChatRoomViewModel(this.userId);

  bool _isSending = false;
  bool get isSending => _isSending;

  Stream<List<ChatMessage>> get messagesStream =>
      _chatService.getMessages(userId);

  Future<void> sendMessage(String text, {String? imageUrl}) async {
    if ((text.trim().isEmpty && imageUrl == null)) return;

    _isSending = true;
    notifyListeners();

    try {
      await _chatService.sendMessage(userId, text, imageUrl: imageUrl);
    } catch (e) {
      debugPrint("Error sending message: $e");
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
