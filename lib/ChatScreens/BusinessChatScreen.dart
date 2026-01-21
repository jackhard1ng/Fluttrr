import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import '../Constants/utils.dart';
import '../Repository/ChatRespository.dart';

class Groupmessagescreen2 extends StatefulWidget {
  final String providerName;
  final String currentuserid;
  final String image;
  final String reciverid;
  final String conversationId;

  const Groupmessagescreen2({
    super.key,
    required this.providerName,
    required this.conversationId,
    required this.currentuserid,
    required this.reciverid,
    required this.image,
  });

  @override
  _Groupmessagescreen2State createState() => _Groupmessagescreen2State();
}

class _Groupmessagescreen2State extends State<Groupmessagescreen2> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _pendingMessages = [];
  final Box _deletedMessagesBox = Hive.box('deleted_messages');
  final List<String> _selectedMessages = [];
  bool _isSelecting = false;
  bool _isDeletingAll = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen('deleted_messages')) {
      await Hive.openBox('deleted_messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 83,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 3,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xff4F78DA),
                  Color(0xff339003),
                ]),
              ),
            )
          ],
        ),
        title: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage("${Apis.ip}${widget.image}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    height: 13,
                    width: 13,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                      child: SizedBox(
                        height: 11,
                        width: 11,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xff339003)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 10),
            Text(widget.providerName),
          ],
        ),
        actions: [
          if (_isSelecting && !_isDeletingAll)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedMessages,
            ),
          if (_isSelecting && _isDeletingAll)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _confirmDeleteAllMessages,
            ),
          if (_isSelecting)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelSelection,
            ),
          if (!_isSelecting)
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Clear All Chat'),
                ),
              ],
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showDeleteAllConfirmation();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SvgPicture.asset(
                  'assets/Group 48096195 (1).svg',
                  height: 27,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSelecting)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isDeletingAll = !_isDeletingAll;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isDeletingAll ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      _isDeletingAll
                          ? 'Deleting All Messages'
                          : 'Deleting Only Mine',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groupChats')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final firestoreMessages = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {
                        ...data,
                        'messageId': doc.id,
                      };
                    })
                    .where(
                        (message) => !_isMessageDeleted(message['messageId']))
                    .toList();

                final pendingMessages = _pendingMessages.where((pending) {
                  return !firestoreMessages.any((firestore) =>
                      firestore['message'] == pending['message'] &&
                      firestore['senderId'] == pending['senderId'] &&
                      (firestore['timestamp'] as Timestamp)
                              .millisecondsSinceEpoch >=
                          (pending['timestamp'] as Timestamp)
                              .millisecondsSinceEpoch);
                }).toList();

                final allMessages = [...firestoreMessages, ...pendingMessages];

                allMessages.sort((a, b) {
                  final aTime = a['timestamp'] as Timestamp;
                  final bTime = b['timestamp'] as Timestamp;
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  reverse: true,
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    final isPending = pendingMessages.contains(message);
                    final isCurrentUser =
                        message['senderId'] == widget.currentuserid;
                    final isSelected = _selectedMessages
                        .contains(message['messageId'] ?? message['tempId']);

                    return GestureDetector(
                      onLongPress: () => _handleLongPress(message),
                      onTap: () {
                        if (_isSelecting) {
                          _toggleMessageSelection(message);
                        }
                      },
                      child: MessageBubble(
                        message: message,
                        isSentByMe: isCurrentUser,
                        isTemp: isPending,
                        senderName: isCurrentUser
                            ? 'You'
                            : message['senderName'] ?? 'Unknown',
                        showSenderName: !isCurrentUser,
                        isSelected: isSelected,
                        isSelecting: _isSelecting,
                        isDeletingAll: _isDeletingAll,
                        onDelete: () => _deleteMessage(message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  bool _isMessageDeleted(String messageId) {
    return _deletedMessagesBox.get('${widget.currentuserid}_$messageId',
        defaultValue: false);
  }

  void _handleLongPress(Map<String, dynamic> message) {
    setState(() {
      _isSelecting = true;
      _toggleMessageSelection(message);
    });
  }

  void _toggleMessageSelection(Map<String, dynamic> message) {
    setState(() {
      final messageId = message['messageId'] ?? message['tempId'];
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
        if (_selectedMessages.isEmpty) {
          _isSelecting = false;
          _isDeletingAll = false;
        }
      } else {
        _selectedMessages.add(messageId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedMessages.clear();
      _isSelecting = false;
      _isDeletingAll = false;
    });
  }

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final messageId = message['messageId'] ?? message['tempId'];
    await _deletedMessagesBox.put('${widget.currentuserid}_$messageId', true);
    setState(() {
      _selectedMessages.remove(messageId);
      if (_selectedMessages.isEmpty) {
        _isSelecting = false;
        _isDeletingAll = false;
      }
    });
  }

  Future<void> _deleteSelectedMessages() async {
    for (var messageId in _selectedMessages) {
      await _deletedMessagesBox.put('${widget.currentuserid}_$messageId', true);
    }
    setState(() {
      _selectedMessages.clear();
      _isSelecting = false;
      _isDeletingAll = false;
    });
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Chat'),
        content: const Text(
            'Are you sure you want to delete all messages from your device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _prepareDeleteAllMessages();
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _prepareDeleteAllMessages() {
    setState(() {
      _isSelecting = true;
      _isDeletingAll = true;
    });
  }

  Future<void> _confirmDeleteAllMessages() async {
    try {
      // Get all message IDs from Firestore
      final snapshot = await _firestore
          .collection('groupChats')
          .doc(widget.conversationId)
          .collection('messages')
          .get();

      // Mark all messages as deleted in Hive
      final Map<String, bool> deletions = {};
      for (var doc in snapshot.docs) {
        deletions['${widget.currentuserid}_${doc.id}'] = true;
      }

      // Perform all deletions in one transaction
      await _deletedMessagesBox.putAll(deletions);

      // Also delete any pending messages
      setState(() {
        _pendingMessages.clear();
        _selectedMessages.clear();
        _isSelecting = false;
        _isDeletingAll = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All messages deleted from your device')),
      );
    } catch (e) {
      print("❌ Error deleting all messages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete messages')),
      );
    }
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffF1F1F1),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SvgPicture.asset(
                      'assets/Group 48095945.svg',
                      height: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/Group 48095946.svg',
                    height: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: sendMessage,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 15),
              child: SvgPicture.asset(
                'assets/sen.svg',
                height: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    String tempId = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> tempMessage = {
      'message': messageText,
      'senderId': widget.currentuserid,
      'senderName': 'You',
      'timestamp': Timestamp.now(),
      'tempId': tempId,
    };

    setState(() {
      _pendingMessages.add(tempMessage);
    });

    _messageController.clear();

    try {
      await Chatrespository()
          .StartConversation2(widget.conversationId, messageText);
    } catch (e) {
      print("❌ Error sending message: $e");
      setState(() {
        _pendingMessages.removeWhere((msg) => msg['tempId'] == tempId);
      });
    }
  }
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isSentByMe;
  final bool isTemp;
  final String senderName;
  final bool showSenderName;
  final bool isSelected;
  final bool isSelecting;
  final bool isDeletingAll;
  final VoidCallback onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.isTemp,
    required this.senderName,
    required this.showSenderName,
    this.isSelected = false,
    this.isSelecting = false,
    this.isDeletingAll = false,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            gradient: isSentByMe
                ? lefttorightgradient.withOpacity(0.4)
                : const LinearGradient(
                    colors: [Color(0xffC6C6C6), Color(0xffC6C6C6)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSenderName)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    senderName,
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (isSelecting && (isSentByMe || isDeletingAll))
                Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onDelete(),
                    ),
                    Expanded(
                      child: Text(
                        message['message'],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  message['message'],
                  style: const TextStyle(color: Colors.black),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  if (isSentByMe)
                    Icon(
                      isTemp ? Icons.access_time : Icons.check,
                      size: 14,
                      color: Colors.black,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    DateTime date = timestamp.toDate();
    String hour =
        date.hour > 12 ? (date.hour - 12).toString() : date.hour.toString();
    String minute = date.minute.toString().padLeft(2, '0');
    String period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }
}
