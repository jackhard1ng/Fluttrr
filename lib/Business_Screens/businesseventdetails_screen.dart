import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BusinessPageController.dart';
import 'package:intl/intl.dart';
import 'package:fluttrr/Models/BusinessModel/BusinessEventListModel.dart';

import 'EditeEventScreen.dart';

class BusinesseventdetailsScreen extends StatefulWidget {
  final Event event;
  final String id;
  const BusinesseventdetailsScreen(
      {super.key, required this.id, required this.event});

  @override
  State<BusinesseventdetailsScreen> createState() =>
      _BusinesseventdetailsScreenState();
}

class _BusinesseventdetailsScreenState
    extends State<BusinesseventdetailsScreen> {
  final BusinessController businessController = Get.put(BusinessController());
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int? _replyingToCommentId;

  @override
  void initState() {
    super.initState();
    businessController.GetEventDetails(widget.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'No date specified';
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('EEEE, MMMM d, y, h:mm a').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  String _timeAgo(String? dateTime) {
    if (dateTime == null) return 'Just now';
    try {
      final parsedDate = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTime;
    }
  }

  void _submitComment() {
    if (_commentController.text.isEmpty) return;
    _commentController.clear();
  }

  void _submitReply(int commentId) {
    if (_replyController.text.isEmpty) return;
    _replyController.clear();
    setState(() {
      _replyingToCommentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: const Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GetBuilder<BusinessController>(
        id: "Activity_update",
        builder: (controller) {
          final event = controller.myEventsDetailsModel?.data;
          final isLoading = controller.isLoading;

          // if (isLoading) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          if (event == null) {
            return const Center(child: Text('Event not found'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 283,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: event.image != null
                                ? NetworkImage("${Apis.ip}${event.image!}")
                                : const AssetImage('assets/tourists-forest.png')
                                    as ImageProvider,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(() =>
                                      EditEventScreen(event: widget.event));
                                },
                                child: SvgPicture.asset(
                                  'assets/Group 48096067.svg',
                                  height: 35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateTime(event.dateTime),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff339003),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '2h ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: lightBlue,
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/timer.svg',
                                      color: lightBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              event.name ?? 'No name',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/pin.svg',
                                  height: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.location ?? 'No location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: lightBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              event.description ?? 'No description',
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${event.totalSlots ?? 0} Slots · ${event.remainingSlots ?? 0} Remaining',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).indicatorColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (event.attendees != null &&
                                        event.attendees!.isNotEmpty)
                                      Stack(
                                        children: [
                                          for (var i = 0;
                                              i <
                                                  (event.attendees!.length > 3
                                                      ? 3
                                                      : event
                                                          .attendees!.length);
                                              i++)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: i * 17.0),
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundImage: event
                                                                .attendees![i]
                                                                .images !=
                                                            null &&
                                                        event.attendees![i]
                                                            .images!.isNotEmpty
                                                    ? NetworkImage(event
                                                        .attendees![i]
                                                        .images!
                                                        .first)
                                                    : const AssetImage(
                                                            'assets/default_profile.png')
                                                        as ImageProvider,
                                              ),
                                            ),
                                        ],
                                      ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${event.attendees?.length ?? 0}/${event.totalSlots ?? 0} Joined',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 30,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: lightBlue,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Join Now',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: whiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 19),
                            const Divider(
                              thickness: 6,
                              color: Color(0xffF1F1F1),
                            ),
                            if (event.comments != null &&
                                event.comments!.isNotEmpty)
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(top: 10),
                                shrinkWrap: true,
                                itemCount: event.comments!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final comment = event.comments![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: comment
                                                              .userImage !=
                                                          null &&
                                                      comment
                                                          .userImage!.isNotEmpty
                                                  ? NetworkImage(
                                                      comment.userImage!.first)
                                                  : const AssetImage(
                                                          'assets/default_profile.png')
                                                      as ImageProvider,
                                            ),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/Rectangle 230.svg'),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 7),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: const Color(
                                                          0xffC6C6C6),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 17,
                                                        vertical: 4,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                              height: 5),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                comment.userName ??
                                                                    'Anonymous',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 7),
                                                              SvgPicture.asset(
                                                                'assets/verify.svg',
                                                                height: 12,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          Text(
                                                            comment.content ??
                                                                'No content',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 49, top: 3),
                                          child: Row(
                                            children: [
                                              Text(
                                                _timeAgo(comment.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 23),
                                              GestureDetector(
                                                onTap: () {},
                                                child: const Text(
                                                  'Like',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 23),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _replyingToCommentId =
                                                        _replyingToCommentId ==
                                                                comment
                                                                    .commentId
                                                            ? null
                                                            : comment.commentId;
                                                  });
                                                },
                                                child: Text(
                                                  'Reply',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        _replyingToCommentId ==
                                                                comment
                                                                    .commentId
                                                            ? Colors.blue
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_replyingToCommentId ==
                                            comment.commentId)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 49, top: 8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _replyController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Write a reply...',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.send),
                                                  onPressed: () => _submitReply(
                                                      comment.commentId!),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (comment.replies != null &&
                                            comment.replies!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 49, top: 8),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  comment.replies!.length,
                                              itemBuilder:
                                                  (context, replyIndex) {
                                                return const SizedBox();
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitComment,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
