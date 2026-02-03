import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/notification_model.dart';
import '../models/privacy_model.dart';
import 'base_repository.dart';

/// Notification repository
class NotificationRepository extends BaseRepository {
  /// Get notifications
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    final response = await get<dynamic>(ApiEndpoints.notifications);
    if (response.success && response.data != null) {
      final data = response.data;
      List<dynamic> notifications = [];

      if (data is Map<String, dynamic>) {
        notifications = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        notifications = data;
      }

      final notificationList = notifications
          .where((e) => e != null)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: notificationList);
    }
    return ApiResponse.failure(error: response.error);
  }
}

/// Privacy repository
class PrivacyRepository extends BaseRepository {
  /// Get privacy settings
  Future<ApiResponse<PrivacySettings>> getPrivacySettings() async {
    return get<PrivacySettings>(
      ApiEndpoints.getPrivacy,
      fromJson: PrivacySettings.fromJson,
    );
  }

  /// Update privacy settings
  Future<ApiResponse<PrivacySettings>> updatePrivacySettings(PrivacySettings settings) async {
    return post<PrivacySettings>(
      ApiEndpoints.updatePrivacy,
      body: settings.toJson(),
      fromJson: PrivacySettings.fromJson,
    );
  }
}

/// Support repository
class SupportRepository extends BaseRepository {
  /// Submit complaint/support ticket
  Future<ApiResponse<dynamic>> submitComplaint({
    required String subject,
    required String description,
    String? category,
  }) async {
    return post(
      ApiEndpoints.submitComplaint,
      body: {
        'subject': subject,
        'description': description,
        if (category != null) 'category': category,
      },
    );
  }
}
