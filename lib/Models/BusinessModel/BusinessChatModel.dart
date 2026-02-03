class BusinessChatList {
  List<ChatList>? chatList;

  BusinessChatList({this.chatList});

  BusinessChatList.fromJson(Map<String, dynamic> json) {
    if (json['chatList'] != null) {
      chatList = <ChatList>[];
      json['chatList'].forEach((v) {
        chatList!.add(ChatList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (chatList != null) {
      data['chatList'] = chatList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatList {
  int? conversationId;
  int? userId;
  List<String>? userImage;
  String? userName;

  int? businessId;
  String? businessName;
  String? logo;

  String? lastMessage;
  LastMessageTime? lastMessageTime;
  int? unseenCount;
  String? lastUpdated;

  ChatList({
    this.conversationId,
    this.userId,
    this.userImage,
    this.userName,
    this.businessId,
    this.businessName,
    this.logo,
    this.lastMessage,
    this.lastMessageTime,
    this.unseenCount,
    this.lastUpdated,
  });

  ChatList.fromJson(Map<String, dynamic> json) {
    conversationId = json['conversationId'];

    // User info
    userId = json['userId'];
    if (json['userImage'] != null) {
      userImage = List<String>.from(json['userImage']);
    }
    userName = json['userName'];

    // Business info
    businessId = json['businessId'];
    businessName = json['businessName'];
    logo = json['logo'];

    // Common fields
    lastMessage = json['lastMessage'];
    if (json['lastMessageTime'] != null) {
      lastMessageTime = LastMessageTime.fromJson(json['lastMessageTime']);
    }
    unseenCount = json['unseenCount'];
    lastUpdated = json['lastUpdated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['conversationId'] = conversationId;

    if (userId != null) data['userId'] = userId;
    if (userImage != null) data['userImage'] = userImage;
    if (userName != null) data['userName'] = userName;

    if (businessId != null) data['businessId'] = businessId;
    if (businessName != null) data['businessName'] = businessName;
    if (logo != null) data['logo'] = logo;

    data['lastMessage'] = lastMessage;
    if (lastMessageTime != null) {
      data['lastMessageTime'] = lastMessageTime!.toJson();
    }
    data['unseenCount'] = unseenCount;
    data['lastUpdated'] = lastUpdated;

    return data;
  }
}

class LastMessageTime {
  int? iSeconds;
  int? iNanoseconds;

  LastMessageTime({this.iSeconds, this.iNanoseconds});

  LastMessageTime.fromJson(Map<String, dynamic> json) {
    iSeconds = json['_seconds'];
    iNanoseconds = json['_nanoseconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_seconds'] = iSeconds;
    data['_nanoseconds'] = iNanoseconds;
    return data;
  }
}
