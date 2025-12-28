import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';

class ChatInboxViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Stream yang akan dikonsumsi UI
  Stream<List<Map<String, dynamic>>> get chatUsersStream {
    return _chatService.getChatUsers().map((users) {
      if (_searchQuery.isEmpty) return users;
      return users.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  // Search logic (Client side filtering simple)
  String _searchQuery = '';
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
