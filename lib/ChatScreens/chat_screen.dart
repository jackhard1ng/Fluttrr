import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';

import '../Constants/utils.dart';
import '../Repository/ChatRespository.dart';

class ChatScreen extends StatefulWidget {
  final String providerName;
  final bool online;
  final String currentuserid;
  final String image;
  final String reciverid;
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.providerName,
    required this.conversationId,
    required this.currentuserid,
    required this.reciverid,
    required this.image,
    required this.online,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Map<String, dynamic>> _pendingMessages = [];
  final Box _deletedMessagesBox = Hive.box('deleted_messages');
  final List<String> _selectedMessages = [];
  bool _isSelecting = false;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImageFiles = [];
  bool _isUploading = false;

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
                  backgroundImage: NetworkImage(widget.image),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: widget.online == true
                      ? Container(
                          height: 13,
                          width: 13,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Center(
                            child: SizedBox(
                              height: 11,
                              width: 11,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff339003)),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                )
              ],
            ),
            const SizedBox(width: 10),
            Text(widget.providerName),
          ],
        ),
        actions: [
          if (_isSelecting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedMessages,
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
          // Selected images preview
          if (_selectedImageFiles.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImageFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(
                                File(_selectedImageFiles[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
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

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markMessagesAsSeen(firestoreMessages);
                });

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
                    final isSeen = message['seen'] ?? false;
                    final images = message['images'] as List<dynamic>?;

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
                        isSelected: isSelected,
                        isSelecting: _isSelecting,
                        isSeen: isSeen,
                        onDelete: () => _deleteMessage(message),
                        images: images?.cast<String>() ?? [],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // if (_isUploading)
          //   const LinearProgressIndicator(),
          _buildInputSection(),
        ],
      ),
    );
  }

  Future<void> _markMessagesAsSeen(List<Map<String, dynamic>> messages) async {
    try {
      final unreadMessages = messages.where((msg) =>
          msg['senderId'] != widget.currentuserid &&
          (msg['seen'] == null || msg['seen'] == false) &&
          msg['messageId'] != null);

      final batch = _firestore.batch();

      for (var msg in unreadMessages) {
        final docRef = _firestore
            .collection('chats')
            .doc(widget.conversationId)
            .collection('messages')
            .doc(msg['messageId']);

        batch.update(docRef, {'seen': true});
      }

      if (unreadMessages.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print("❌ Error marking messages as seen: $e");
    }
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
    });
  }

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final messageId = message['messageId'] ?? message['tempId'];
    await _deletedMessagesBox.put('${widget.currentuserid}_$messageId', true);
    setState(() {
      _selectedMessages.remove(messageId);
      if (_selectedMessages.isEmpty) {
        _isSelecting = false;
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
              _confirmDeleteAllMessages();
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAllMessages() async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(widget.conversationId)
          .collection('messages')
          .get();

      final Map<String, bool> deletions = {};
      for (var doc in snapshot.docs) {
        deletions['${widget.currentuserid}_${doc.id}'] = true;
      }

      await _deletedMessagesBox.putAll(deletions);

      setState(() {
        _pendingMessages.clear();
        _selectedMessages.clear();
        _isSelecting = false;
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: _pickImages,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _takePhoto,
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImageFiles.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print("❌ Error picking images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImageFiles.add(photo);
        });
      }
    } catch (e) {
      print("❌ Error taking photo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to take photo')),
      );
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
    });
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty && _selectedImageFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      List<File> imageFiles =
          _selectedImageFiles.map((xfile) => File(xfile.path)).toList();

      String tempId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create temp message before sending to show immediately
      Map<String, dynamic> tempMessage = {
        'message': messageText,
        'senderId': widget.currentuserid,
        'receiverId': widget.reciverid,
        'timestamp': Timestamp.now(),
        'seen': false,
        'tempId': tempId,
        'images': imageFiles.isNotEmpty
            ? ["uploading..."] // Placeholder for images
            : [],
      };

      setState(() {
        _pendingMessages.add(tempMessage);
        _messageController.clear();
        _selectedImageFiles.clear();
      });

      // Send message through your API
      await Chatrespository().StartConversation(
        widget.reciverid,
        messageText, // Use the saved messageText, not controller.text
        imageFiles,
      );

      // Update Firestore if needed
      await _firestore
          .collection('chats')
          .doc(widget.conversationId)
          .update({'lastMessageTime': Timestamp.now()});
    } catch (e) {
      print("❌ Error sending message: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      // );

      // Remove the pending message if it fails
      // setState(() {
      //   _pendingMessages.removeWhere((msg) => msg['tempId'] == tempId);
      // });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isSentByMe;
  final bool isTemp;
  final bool isSelected;
  final bool isSelecting;
  final bool isSeen;
  final VoidCallback onDelete;
  final List<String> images;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.isTemp,
    this.isSelected = false,
    this.isSelecting = false,
    required this.onDelete,
    required this.isSeen,
    required this.images,
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isSelecting && isSentByMe)
                Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onDelete(),
                    ),
                    Expanded(
                      child: _buildMessageContent(),
                    ),
                  ],
                )
              else
                _buildMessageContent(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  if (isSentByMe)
                    Row(
                      children: [
                        Icon(
                          isTemp
                              ? Icons.access_time
                              : isSeen
                                  ? Icons.check
                                  : Icons.check,
                          size: 14,
                          color: isTemp
                              ? Colors.black
                              : isSeen
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        if (!isTemp && isSeen)
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    final hasImages = images.isNotEmpty;
    final hasText =
        message['message'] != null && message['message'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImages)
          Column(
            children: images.map((imageUrl) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "${Apis.ip}$imageUrl",
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        if (hasText)
          Text(
            message['message'],
            style: const TextStyle(color: Colors.black),
          ),
      ],
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
