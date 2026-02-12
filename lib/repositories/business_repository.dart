import 'dart:io';

import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/business_model.dart';
import 'base_repository.dart';

/// Business repository
class BusinessRepository extends BaseRepository {
  /// Get business profile
  Future<ApiResponse<BusinessModel>> getBusinessProfile() async {
    // Manually unwrap { success, data } wrapper since base_repository
    // passes the full response to fromJson
    final response = await get<dynamic>(ApiEndpoints.businessProfile);

    if (response.success && response.data != null) {
      final raw = response.data;
      Map<String, dynamic>? profileData;
      if (raw is Map<String, dynamic>) {
        profileData = raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw;
      }
      if (profileData != null) {
        return ApiResponse.success(data: BusinessModel.fromJson(profileData));
      }
    }
    return ApiResponse.failure(error: response.error ?? 'Failed to get business profile');
  }

  /// Create business profile
  Future<ApiResponse<BusinessModel>> createBusinessProfile({
    required String businessName,
    required String email,
    required String phone,
    required String description,
    required String category,
    required String address,
    String? location,
    double? latitude,
    double? longitude,
    String? website,
    String? facebook,
    String? instagram,
    File? profileImage,
    File? coverImage,
  }) async {
    // If no images, use regular POST
    if (profileImage == null && coverImage == null) {
      return post<BusinessModel>(
        ApiEndpoints.createBusinessProfile,
        body: {
          'businessName': businessName,
          'email': email,
          'phone': phone,
          'description': description,
          'category': category,
          'address': address,
          if (location != null) 'location': location,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (website != null) 'website': website,
          if (facebook != null) 'facebook': facebook,
          if (instagram != null) 'instagram': instagram,
        },
        fromJson: BusinessModel.fromJson,
      );
    }

    // Use multipart upload when images are provided
    final files = <String, File>{};
    if (profileImage != null) files['profileImage'] = profileImage;
    if (coverImage != null) files['coverImage'] = coverImage;

    final fields = <String, String>{
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'description': description,
      'category': category,
      'address': address,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (website != null) 'website': website,
      if (facebook != null) 'facebook': facebook,
      if (instagram != null) 'instagram': instagram,
    };

    return uploadMultipleFiles<BusinessModel>(
      ApiEndpoints.createBusinessProfile,
      files: files,
      fields: fields,
      fromJson: BusinessModel.fromJson,
    );
  }

  /// Upload or update business profile image
  Future<ApiResponse<BusinessModel>> uploadBusinessProfileImage(File image) async {
    return uploadFile<BusinessModel>(
      ApiEndpoints.businessProfileImage,
      file: image,
      fieldName: 'profileImage',
      fromJson: BusinessModel.fromJson,
    );
  }

  /// Upload or update business cover image
  Future<ApiResponse<BusinessModel>> uploadBusinessCoverImage(File image) async {
    return uploadFile<BusinessModel>(
      ApiEndpoints.businessCoverImage,
      file: image,
      fieldName: 'coverImage',
      fromJson: BusinessModel.fromJson,
    );
  }

  /// Send business OTP for email verification
  Future<ApiResponse<dynamic>> sendBusinessOtp({required String email}) async {
    return post(
      ApiEndpoints.businessRequestOtp,
      body: {'email': email},
    );
  }

  /// Verify business OTP
  Future<ApiResponse<dynamic>> verifyBusinessOtp({
    required String email,
    required String otp,
  }) async {
    return post(
      ApiEndpoints.businessVerify,
      body: {'email': email, 'otp': otp},
    );
  }

  /// Get subscription status
  Future<ApiResponse<SubscriptionStatus>> getSubscriptionStatus() async {
    return get<SubscriptionStatus>(
      ApiEndpoints.subscriptionStatus,
      fromJson: SubscriptionStatus.fromJson,
    );
  }

  /// Update business profile
  Future<ApiResponse<BusinessModel>> updateBusinessProfile({
    required int businessId,
    String? businessName,
    String? email,
    String? phone,
    String? description,
    String? category,
    String? address,
    String? location,
    double? latitude,
    double? longitude,
    String? website,
    String? facebook,
    String? instagram,
  }) async {
    final body = <String, dynamic>{};
    if (businessName != null) body['businessName'] = businessName;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (address != null) body['address'] = address;
    if (location != null) body['location'] = location;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (website != null) body['website'] = website;
    if (facebook != null) body['facebook'] = facebook;
    if (instagram != null) body['instagram'] = instagram;

    return put<BusinessModel>(
      '${ApiEndpoints.updateBusinessProfile}$businessId',
      body: body,
      fromJson: BusinessModel.fromJson,
    );
  }

  /// Request business verification OTP
  Future<ApiResponse<dynamic>> requestVerificationOtp(String email) async {
    return post(
      ApiEndpoints.businessRequestOtp,
      body: {'email': email},
    );
  }

  /// Verify business
  Future<ApiResponse<dynamic>> verifyBusiness({
    required String email,
    required String otp,
  }) async {
    return post(
      ApiEndpoints.businessVerify,
      body: {'email': email, 'otp': otp},
    );
  }

  /// Get business status
  Future<ApiResponse<dynamic>> getBusinessStatus() async {
    return get(ApiEndpoints.businessStatus);
  }

  /// Get business events list
  Future<ApiResponse<List<BusinessEvent>>> getBusinessEvents() async {
    final response = await get<dynamic>(ApiEndpoints.businessEventList);
    return _parseBusinessEventsList(response);
  }

  /// Get my business events
  Future<ApiResponse<List<BusinessEvent>>> getMyBusinessEvents() async {
    final response = await get<dynamic>(ApiEndpoints.myBusinessEvents);
    return _parseBusinessEventsList(response);
  }

  /// Create business event
  Future<ApiResponse<BusinessEvent>> createBusinessEvent({
    required String name,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required DateTime startTime,
    DateTime? endTime,
    required String eventType,
    required int totalSlots,
    double? price,
    String? currency,
    List<File>? images,
  }) async {
    // Don't use fromJson param — base_repository passes the full
    // { success, data } wrapper; we unwrap 'data' ourselves.
    final response = await post<dynamic>(
      ApiEndpoints.createBusinessEvent,
      body: {
        'name': name,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        'eventType': eventType,
        'totalSlots': totalSlots,
        if (price != null) 'price': price,
        if (currency != null) 'currency': currency,
      },
    );

    if (response.success && response.data != null) {
      final raw = response.data;
      Map<String, dynamic>? eventData;
      if (raw is Map<String, dynamic>) {
        eventData = raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw;
      }
      if (eventData != null) {
        return ApiResponse.success(data: BusinessEvent.fromJson(eventData));
      }
    }
    return ApiResponse.failure(error: response.error ?? 'Failed to create event');
  }

  /// Update business event
  Future<ApiResponse<BusinessEvent>> updateBusinessEvent({
    required int eventId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    String? eventType,
    int? totalSlots,
    double? price,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (startTime != null) body['startTime'] = startTime.toIso8601String();
    if (endTime != null) body['endTime'] = endTime.toIso8601String();
    if (eventType != null) body['eventType'] = eventType;
    if (totalSlots != null) body['totalSlots'] = totalSlots;
    if (price != null) body['price'] = price;

    return put<BusinessEvent>(
      '${ApiEndpoints.updateBusinessEvent}$eventId',
      body: body,
      fromJson: BusinessEvent.fromJson,
    );
  }

  /// Get business event details
  Future<ApiResponse<BusinessEvent>> getBusinessEventDetails(int eventId) async {
    return get<BusinessEvent>(
      '${ApiEndpoints.businessEventDetails}$eventId',
      fromJson: BusinessEvent.fromJson,
    );
  }

  /// Delete business event
  Future<ApiResponse<dynamic>> deleteBusinessEvent(int eventId) async {
    return delete('${ApiEndpoints.deleteBusinessEvent}$eventId');
  }

  /// Join business event
  Future<ApiResponse<dynamic>> joinBusinessEvent(int eventId) async {
    return post(
      ApiEndpoints.joinBusinessEvent,
      body: {'eventId': eventId},
    );
  }

  /// Leave business event
  Future<ApiResponse<dynamic>> leaveBusinessEvent(int eventId) async {
    return post(
      ApiEndpoints.leaveBusinessEvent,
      body: {'eventId': eventId},
    );
  }

  /// Save/unsave business event
  Future<ApiResponse<dynamic>> toggleSaveBusinessEvent(int eventId) async {
    return post(
      ApiEndpoints.saveBusinessEvent,
      body: {'eventId': eventId},
    );
  }

  /// Get saved events list
  Future<ApiResponse<List<BusinessEvent>>> getSavedEvents() async {
    final response = await get<dynamic>(ApiEndpoints.savedEventsList);
    return _parseBusinessEventsList(response);
  }

  /// Get top events
  Future<ApiResponse<List<BusinessEvent>>> getTopEvents() async {
    final response = await get<dynamic>(ApiEndpoints.topEvents);
    return _parseBusinessEventsList(response);
  }

  /// Record event click
  Future<ApiResponse<dynamic>> recordEventClick(int eventId) async {
    return post('${ApiEndpoints.eventClicks}$eventId/click');
  }

  /// Record event view
  Future<ApiResponse<dynamic>> recordEventView(int eventId) async {
    return post('${ApiEndpoints.eventViews}$eventId/view');
  }

  /// Follow business
  Future<ApiResponse<dynamic>> followBusiness(int businessId) async {
    return post(
      ApiEndpoints.followBusiness,
      body: {'businessId': businessId},
    );
  }

  /// Unfollow business
  Future<ApiResponse<dynamic>> unfollowBusiness(int businessId) async {
    return post(
      ApiEndpoints.unfollowBusiness,
      body: {'businessId': businessId},
    );
  }

  /// Create subscription
  Future<ApiResponse<dynamic>> createSubscription({
    required String planId,
    required String paymentMethodId,
  }) async {
    return post(
      ApiEndpoints.createSubscription,
      body: {
        'planId': planId,
        'paymentMethodId': paymentMethodId,
      },
    );
  }

  /// Cancel subscription
  Future<ApiResponse<dynamic>> cancelSubscription() async {
    return post(ApiEndpoints.cancelSubscription);
  }

  /// Get business analytics with optional period filter (7d, 30d, 90d, all)
  Future<ApiResponse<BusinessAnalytics>> getBusinessAnalytics({String period = 'all'}) async {
    return get<BusinessAnalytics>(
      '${ApiEndpoints.businessAnalytics}?period=$period',
      fromJson: BusinessAnalytics.fromJson,
    );
  }

  /// Helper method to parse business events list response
  ApiResponse<List<BusinessEvent>> _parseBusinessEventsList(ApiResponse<dynamic> response) {
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> events = [];

      if (data is Map<String, dynamic>) {
        final rawEvents = data['data'];
        events = (rawEvents is List) ? rawEvents : [];
      } else if (data is List) {
        events = data;
      }

      final eventsList = events
          .whereType<Map<String, dynamic>>()
          .map((e) => BusinessEvent.fromJson(e))
          .toList();

      return ApiResponse.success(data: eventsList);
    }
    return ApiResponse.failure(error: response.error);
  }
}
