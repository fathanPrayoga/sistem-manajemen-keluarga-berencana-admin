import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';

class ChatInboxViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Stream yang akan dikonsumsi UI
  Stream<List<Map<String, dynamic>>> get chatUsersStream =>
      _chatService.getChatUsers();

  // Search logic (Client side filtering simple)
  String _searchQuery = '';
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
