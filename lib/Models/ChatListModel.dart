class ChatListModel {
  String? message;
  List<ChatList>? chatList;

  ChatListModel({this.message, this.chatList});

  ChatListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['chatList'] != null) {
      chatList = <ChatList>[];
      json['chatList'].forEach((v) {
        chatList!.add(ChatList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (chatList != null) {
      data['chatList'] = chatList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatList {
  int? userID;
  String? userName;
  List<String>? profileImage;
  bool? isOnline;
  String? lastMessage;
  String? lastMessageTime;
  int? unreadMessages;
  int? conversationId;

  ChatList(
      {this.userID,
        this.userName,
        this.profileImage,
        this.isOnline,
        this.lastMessage,
        this.lastMessageTime,
        this.unreadMessages,
        this.conversationId});

  ChatList.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    profileImage = json['profileImage'].cast<String>();
    isOnline = json['isOnline'];
    lastMessage = json['lastMessage'];
    lastMessageTime = json['lastMessageTime'];
    unreadMessages = json['unreadMessages'];
    conversationId = json['conversationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['userName'] = userName;
    data['profileImage'] = profileImage;
    data['isOnline'] = isOnline;
    data['lastMessage'] = lastMessage;
    data['lastMessageTime'] = lastMessageTime;
    data['unreadMessages'] = unreadMessages;
    data['conversationId'] = conversationId;
    return data;
  }
}
