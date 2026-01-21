

class Apis{


// static String ip="https://fluttrr.com";
static String ip="http://82.180.139.134:3001";
// static String ip="http://192.168.1.5:3001";
// BaseUrl
static String baseurl="$ip/api";

//..........................Authentication Api endpoints
  static String Login="$baseurl/user/login";
  static  String verifyotp="$baseurl/user/verify-otp";
  static  String googlelogin="$baseurl/user/google-login";
  static  String sendotp="$baseurl/user/send-otp";
  static  String changepassword="$baseurl/user/change-password";
  static  String ForgetPassword="$baseurl/user/reset-password";
  static  String ForgetSendOTp="$baseurl/user/request-otp";
  static  String ForgetVerifyOtp="$baseurl/user/verifys-otp";

//.........................Profile..............................
  static String Profile="$baseurl/user/profile";
  static String GalleryList="$baseurl/gallery/list";
  static String GalleryUpload="$baseurl/gallery/upload";
  static String EditeProfile="$baseurl/user/update";
  static String TotalActivity="$baseurl/activity/created-activities-count";
  static String TotalMatch="$baseurl/mate/total-mates";
  static String JoinedActivites="$baseurl/activity/joined-activities-count";
  static String userMatches="$baseurl/mate/liked-mates";
  static String ListJoinedActivites="$baseurl/activity/user-activities";
  static String UpdateLocation="$baseurl/user/update-location";
  static String UpdateFCMToken="$baseurl/user/token";
  static String SetupProfile="$baseurl/user/create-profile";
  static String online="$baseurl/user/online";
  static String offline="$baseurl/user/offline";
  static String percentage="$baseurl/user/monitring";








//.........................Mates profileView.....................
  static String MateProfile="$baseurl/privacy/profile";


//......................... Mates...............................
  static String Mates="$baseurl/mate/filter";
  static String nearbyMates="$baseurl/mate/nearby";
  static String MatesList="$baseurl/user/List";
  static String ViewbyDistance="$baseurl/mate/find-nearby-mates";
  static String MatchMates="$baseurl/user/match";
  static String NearbyFilter="$baseurl/user/search";
  static String LikedMate="$baseurl/mate/like";




//.........................Activity..............................
  static String dailyactivities="$baseurl/activity/daily-activities";
  static String ActivityList="$baseurl/activity/list";
  static String CreateActivity="$baseurl/activity/create-activity";
  static String DetailActivity="$baseurl/activity/activity-details";
  static String EventDetails="$baseurl/bussness/list";
  static String MyActivity="$baseurl/activity/my-activity";
  static String joinActivity="$baseurl/activity/join";
  static String joinEvent="$baseurl/bussness/joinEvent";
  static String saveActivity="$baseurl/activity/save";
  static String saveEvent="$baseurl/bussness/saveEvent";
  static String saveList="$baseurl/bussness/saveList";
  static String FilterActivites="$baseurl/activity/search";
  static String LeaveActivites="$baseurl/activity/leave";
  static String LeaveEvent="$baseurl/bussness/leaveEvent";
  static String UpdateActivity="$baseurl/activity/update";
  static String DeleteActivity="$baseurl/activity/delete";
  static String UpcomingActivity="$baseurl/activity/upcoming";



//......................privacyPolicy..............................
  static String UpdatePolicy="$baseurl/privacy/updatePrivacy";
  static String Getprivacy="$baseurl/privacy/getPrivacySettings";


//..........................Chats....................................
  static String StartConverstaion="$baseurl/message/send";
  static String GetChatsList="$baseurl/message/cheatlist";
  static String grouplist="$baseurl/message/grouplist";
  static String Markasread="$baseurl/message/markAsRead";
  static String GetBusinessChats="$baseurl/message/getChatList";
  static String StartBusinesschat="$baseurl/message/sendB";




//............................BusinessPage..................................
  static String RequestOtp="$baseurl/bussness/request-otp";
  static String RequestVerify="$baseurl/bussness/verify";
  static String CreateEvent="$baseurl/bussness/createEvent";
  static String GetCreatedEvent="$baseurl/bussness/eventList";
  static String GetBusinessPage="$baseurl/bussness/busness";
  static String CreateBusinessProfile="$baseurl/bussness/create-profile";
  static String UpdateBussinessPage="$baseurl/bussness/updates/";
  static String EditeEvent="$baseurl/bussness/updateEvent/";
  static String Analytics="$baseurl/bussness/analytics";
  static String MYEventDetails="$baseurl/bussness/eventById/";
  static String Subscription="$baseurl/bussness/create";
  static String CancelSubscription="$baseurl/bussness/cancel";
  static String BusinessStatus="$baseurl/bussness/bussnesStatus";
  static String TopEvents="$baseurl/bussness/topEvent";
  static String followBusiness="$baseurl/bussness/follow";
  static String unfollowbusiness="$baseurl/bussness/unfollow";
  static String eventClicks="$baseurl/bussness/events/";
  static String eventview="$baseurl/bussness/events/";



//...........................Badges List.........................
  static String BadgesList="$baseurl/user/achiveList";
  static String BadgesVerified="$baseurl/user/claimed";
  static String LeaderBoard="$baseurl/user/ranking";


//..............................Notifications..............................

  static String NotificationScreen="$baseurl/mate/list_notifications";


  //..............................Notifications..............................

  static String Compalin="$baseurl/admin/complain";



}