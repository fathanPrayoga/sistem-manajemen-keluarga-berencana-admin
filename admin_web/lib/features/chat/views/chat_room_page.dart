import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/chat_room_viewmodel.dart';
import '../../../models/chat_model.dart';

class ChatRoomPage extends StatelessWidget {
  final String userId;
  final String userName;

  const ChatRoomPage({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatRoomViewModel(userId),
      child: _ChatRoomView(userName: userName),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final String userName;
  const _ChatRoomView({required this.userName});

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mark conversation as read for admin when opening the chat room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ChatRoomViewModel>();
      viewModel.markAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatRoomViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: viewModel.messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  reverse: true, // Pesan terbaru di bawah
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == 'admin';

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 2, color: Colors.grey.shade200),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {},
                ), // TODO: Image Picker
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) => _sendMessage(viewModel),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () => _sendMessage(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatRoomViewModel viewModel) {
    if (_textController.text.trim().isNotEmpty) {
      viewModel.sendMessage(_textController.text);
      _textController.clear();
    }
  }
}
