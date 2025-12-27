import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/chat_inbox_viewmodel.dart';

class ChatInboxPage extends StatelessWidget {
  const ChatInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatInboxViewModel(),
      child: const _ChatInboxView(),
    );
  }
}

class _ChatInboxView extends StatelessWidget {
  const _ChatInboxView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatInboxViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari user...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: viewModel.setSearchQuery,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: viewModel.chatUsersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('Belum ada konsultasi'));
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              final lastTime = user['lastMessageTime'] as DateTime?;
              final timeString = lastTime != null
                  ? DateFormat('dd MMM HH:mm').format(lastTime)
                  : '';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(user['displayName'][0].toUpperCase()),
                ),
                title: Text(
                  user['displayName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  user['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeString,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (user['unreadCount'] > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${user['unreadCount']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // Navigasi ke Chat Room
                  context.go(
                    '/chat/${user['uid']}',
                    extra: user['displayName'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
