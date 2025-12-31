import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added this import
import '../viewmodels/chat_room_viewmodel.dart';
import '../../../models/chat_model.dart';

class ChatRoomPage extends StatelessWidget {
  final String chatPath; // Ini adalah encoded path dari router
  final String userName;

  const ChatRoomPage(
      {super.key, required this.chatPath, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Decode path jika perlu, tapi biasanya router sudah handle jika passed as param.
    // Tapi karena kita manual encodeComponent sebelumnya, kita decodeComponent di sini.
    final decodedPath = Uri.decodeComponent(chatPath);

    return ChangeNotifierProvider(
      create: (_) => ChatRoomViewModel(decodedPath),
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
  DateTime? _lastReadTime;

  @override
  void initState() {
    super.initState();
    _initReadStatus();
  }

  Future<void> _initReadStatus() async {
    final viewModel = context.read<ChatRoomViewModel>();
    try {
      // 1. Fetch last read time
      final doc =
          await FirebaseFirestore.instance.doc(viewModel.chatPath).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        if (data != null) {
          final dynamic ts = data['lastReadTimestampAdmin'];
          if (ts is Timestamp) {
            setState(() {
              _lastReadTime = ts.toDate();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching read status: $e");
    }

    // 2. Mark as read
    if (mounted) {
      viewModel.markAsRead();
    }
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

                    // Divider Logic
                    // Because list is reversed (index 0 is NEWEST),
                    // We want divider ABOVE the OLDEST unread message.
                    // "Above" in reverse list means "After" the item in the list (index + 1)
                    // But wait, visually "Above" means visually earlier in time.
                    // Since it's reversed:
                    // [Newest (idx 0), Newer, Divider, Unread Oldest (idx 2), Read (idx 3)]
                    // So if idx 2 is Unread, and idx 3 is Read (or time <= lastRead), then Divider is *between* 2 and 3.
                    // Since itemBuilder builds item at index, we can attach divider to the *bottom* of index 2 (which is visual top).

                    bool showDivider = false;
                    if (_lastReadTime != null) {
                      final msgTime = message.timestamp;
                      // Check if THIS message is Unread
                      if (msgTime.isAfter(_lastReadTime!)) {
                        // Check if next item (visually previous/older) is Read or doesn't exist
                        if (index == messages.length - 1) {
                          // This is the oldest message and it is unread -> Show Divider above it
                          showDivider = true;
                        } else {
                          final olderMessage = messages[index + 1];
                          if (!olderMessage.timestamp.isAfter(_lastReadTime!)) {
                            showDivider = true;
                          }
                        }
                      }
                    }

                    final messageWidget = Align(
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

                    if (showDivider) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: Colors.red)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'Pesan Belum Terbaca',
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                    child: Divider(color: Colors.red)),
                              ],
                            ),
                          ),
                          messageWidget,
                        ],
                      );
                    }
                    return messageWidget;
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
