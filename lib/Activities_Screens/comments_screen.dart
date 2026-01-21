import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import '../Models/CommentsModel.dart';

class CommentsScreen extends StatefulWidget {
  final String id;
  final bool event;
  const CommentsScreen({super.key, required this.id, required this.event});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Comment> comments = [];
  final TextEditingController _replyController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  int? replyingToCommentId;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    Uri urievent = widget.event == false
        ? Uri.parse("${Apis.baseurl}/comment/${widget.id}")
        : Uri.parse("${Apis.baseurl}/comment/event/${widget.id}");
    // Uri uriactivity=Uri.parse("${Apis.baseurl}/comment/${widget.id}");

    final response = await http.get(urievent);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      CommentsModel commentsModel = CommentsModel.fromJson(jsonData);
      setState(() {
        comments = commentsModel.comments ?? [];
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _postReply(int parentCommentId, String content) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    print("The token is : $token");
    final response = await http.post(
      Uri.parse('${Apis.baseurl}/comment/add'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "activityId": widget.id,
        'parentCommentId': parentCommentId,
        'content': content
      }),
    );
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _fetchComments();
      setState(() {
        replyingToCommentId = null;
        _replyController.clear();
      });
    }
  }

  Future<void> _postComment(String content) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    print("The token is : $token");
    final response = await http.post(
      Uri.parse('${Apis.baseurl}/comment/add'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        if (widget.event == false) "activityId": widget.id,
        if (widget.event) "eventId": widget.id,
        'content': content
      }),
    );
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _fetchComments();
      setState(() {
        replyingToCommentId = null;
        _postController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 66, left: 20),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.arrow_back)),
                SizedBox(width: 30),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 13),
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(gradient: lefttorightgradient),
          ),
          Expanded(
            child: comments.isEmpty
                ? Center(child: CircularProgressIndicator())
                : _buildCommentsList(comments),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<Comment> comments) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return _buildCommentItem(comments[index]);
      },
    );
  }

  Widget _buildCommentItem(Comment comment, {double leftPadding = 20}) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: comment
                            .user?.userProfile?.images?.isNotEmpty ==
                        true
                    ? NetworkImage(
                        "${Apis.ip}${comment.user!.userProfile!.images!.first}")
                    : AssetImage('assets/default_avatar.png')
                        as ImageProvider, // Fallback image
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Colors.grey[300], // Softer color for better readability
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.user?.userName ?? 'Unknown',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          comment.content ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 49, top: 3),
            child: Wrap(
              spacing: 20,
              children: [
                Text(
                  timeago.format(DateTime.parse(
                      comment.createdAt ?? DateTime.now().toIso8601String())),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
                Text('Like',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      replyingToCommentId = comment.commentID;
                    });
                  },
                  child: Text('Reply',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue)),
                ),
              ],
            ),
          ),

          // Reply Input Field
          if (replyingToCommentId == comment.commentID)
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 5),
              child: _buildReplyInput(comment.commentID!),
            ),

          // Display Replies
          if (comment.replies != null && comment.replies!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 30, top: 5),
              child: Column(
                children: comment.replies!
                    .map((reply) =>
                        _buildCommentItem(reply, leftPadding: leftPadding + 20))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (_postController.text.isNotEmpty) {
                _postComment(_postController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput(int parentCommentId) {
    return Padding(
      padding: EdgeInsets.only(left: 50, top: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (_replyController.text.isNotEmpty) {
                _postReply(parentCommentId, _replyController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
