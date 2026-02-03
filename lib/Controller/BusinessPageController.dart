import 'dart:io';

import 'package:get/get.dart';
import 'package:fluttrr/Models/BusinessModel/AnalyticsModel.dart';
import 'package:fluttrr/Models/BusinessModel/BusinessEventListModel.dart';
import 'package:fluttrr/Models/BusinessModel/BusinessPageModel.dart';
import 'package:fluttrr/Models/BusinessModel/BusinessStatusModel.dart';
import 'package:fluttrr/Models/BusinessModel/TopEventsModel.dart';
import 'package:fluttrr/Repository/BusinessPageRepository.dart';

import '../Models/BusinessModel/BusinessChatModel.dart';
import '../Models/BusinessModel/MyBusinessEventModel.dart';

class BusinessController extends GetxController {
  BusinessPageModel? businessPageModel;
  BusinessEventListModel? businessEventListModel;
  AnalyticsModel? analyticsModel;
  MYEventsDetailsModel? myEventsDetailsModel;
  final RxBool isLoading = false.obs;
  BusinessstatusModel? businessstatusModel;
  TopEventModel? topEventModel;
  BusinessChatList? businessChatList;

//.................................SendOtp User.................................
  Future<bool> SendOtp(String email) async {
    final SendOtp = await BusinessRepository().SendOtp(email);
    print("SendOtp Fatch is : $SendOtp");
    if (SendOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//.................................VerifyOtp User.................................
  Future<bool> VerifyOtp(String otp, String email) async {
    final VerifyOtp = await BusinessRepository().VerifyOtp(otp, email);
    print("VerifyOtp Fatch is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//...............................Create Event ..................................
  Future<bool> CreateEvent(
    String businessId,
    String name,
    String dateTime,
    String EndTime,
    String eventPrivacy,
    String attendeesLimit,
    String latitude,
    String longitude,
    String details,
    String eventType,
    String ticketingWebsite,
    String price,
    String location,
    File images,
  ) async {
    final VerifyOtp = await BusinessRepository().createEvent(
        businessId: businessId,
        name: name,
        dateTime: dateTime,
        eventPrivacy: eventPrivacy,
        attendeesLimit: attendeesLimit,
        latitude: latitude,
        longitude: longitude,
        details: details,
        eventType: eventType,
        ticketingWebsite: ticketingWebsite,
        price: price,
        location: location,
        images: images,
        endTime: EndTime);
    print("Form Response is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//.................................Create Business Page.................................
  Future<bool> CreateBussinessPage(
    String name,
    String description,
    String email,
    String phoneNumber,
    String websiteLink,
    String facebookLink,
    String instagramLink,
    File logo,
    File image,
  ) async {
    final VerifyOtp = await BusinessRepository().createBusinessPage(
        name: name,
        description: description,
        email: email,
        phoneNumber: phoneNumber,
        websiteLink: websiteLink,
        facebookLink: facebookLink,
        instagramLink: instagramLink,
        logo: logo,
        image: image);
    print("VerifyOtp Fatch is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//...................................Get Business page ....................

  Future<bool> GetBusinessPage() async {
    final activity = await BusinessRepository().GetDailyActivites();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      businessPageModel = BusinessPageModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//...................................Get Business Events ....................

  Future<bool> GetMYEvents() async {
    final activity = await BusinessRepository().MyEvents();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      businessEventListModel = BusinessEventListModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//................................Update Business Page......................

  Future<bool> updateBusinessPage(
    String id,
    String name,
    String description,
    String email,
    String phoneNumber,
    String websiteLink,
    String facebookLink,
    String instagramLink,
    File? logo,
    File? image,
  ) async {
    final VerifyOtp = await BusinessRepository().EditeBusinessPage(
        name: name,
        description: description,
        email: email,
        phoneNumber: phoneNumber,
        websiteLink: websiteLink,
        facebookLink: facebookLink,
        instagramLink: instagramLink,
        logo: logo,
        image: image,
        id: id);
    print("VerifyOtp Fatch is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//...............................Update Event ..................................
  Future<bool> updateEvent(
    String id,
    String businessId,
    String name,
    String dateTime,
    String EndTime,
    String eventPrivacy,
    String attendeesLimit,
    String latitude,
    String longitude,
    String details,
    String eventType,
    String ticketingWebsite,
    String price,
    String location,
    File? images,
  ) async {
    final VerifyOtp = await BusinessRepository().EditeEvent(
        businessId: businessId,
        name: name,
        dateTime: dateTime,
        eventPrivacy: eventPrivacy,
        attendeesLimit: attendeesLimit,
        latitude: latitude,
        longitude: longitude,
        details: details,
        eventType: eventType,
        ticketingWebsite: ticketingWebsite,
        price: price,
        location: location,
        images: images,
        endTime: EndTime,
        id: id);
    print("VerifyOtp Fatch is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//...................................Get Business Analytics ....................

  Future<bool> GetBussinessAnalytics() async {
    final activity = await BusinessRepository().GetBusinessAnalytics();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      analyticsModel = AnalyticsModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//...................................Get Business Details ....................

  Future<bool> GetEventDetails(String id) async {
    final activity = await BusinessRepository().GetEventdetials(id);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      myEventsDetailsModel = MYEventsDetailsModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//...................................Get Subscription  ....................

  Future<bool> Subscription() async {
    final activity = await BusinessRepository().SubsCription();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      // myEventsDetailsModel = MYEventsDetailsModel.fromJson(activity);
      // update(["Activity_update"]);
      return true;
    }
  }

//...................................Cancel Subscription  ....................

  Future<bool> CancelSubscription() async {
    final activity = await BusinessRepository().CancelSubsCription();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      // myEventsDetailsModel = MYEventsDetailsModel.fromJson(activity);
      // update(["Activity_update"]);
      return true;
    }
  }

//...................................Business Status  ....................

  Future<bool> BusinessStatus() async {
    final activity = await BusinessRepository().BusinessStatusCheck();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      businessstatusModel = BusinessstatusModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //...................................Top Events Status  ....................

  Future<bool> TopEvents() async {
    final activity = await BusinessRepository().TopEvent();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      topEventModel = TopEventModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //................................Business chats ...........................

  Future<bool> BusinessChats(String id, String type) async {
    final activity = await BusinessRepository().BusinessChatList(id, type);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      businessChatList = BusinessChatList.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//.............................BusinessStartChat..........................

  Future<bool> StartBusinessChats(
      String senderid, String businesid, String message) async {
    final activity = await BusinessRepository()
        .StartBusinessChatSend(senderid, businesid, message);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      businessChatList = BusinessChatList.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }
}
