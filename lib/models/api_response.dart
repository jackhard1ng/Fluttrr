/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({String? error, String? message, int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error ?? message,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String errorMessage, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: errorMessage,
      message: errorMessage,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;

  String get displayMessage => message ?? error ?? 'An error occurred';
}

/// Auth response model
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final int? userId;
  final bool isNewUser;
  final bool requiresProfileSetup;

  const AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.userId,
    this.isNewUser = false,
    this.requiresProfileSetup = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] == true || json['token'] != null,
      message: json['message'] as String?,
      token: json['token'] as String?,
      userId: (json['userId'] ?? json['user_id']) as int?,
      isNewUser: json['is_new_user'] == true || json['isNewUser'] == true,
      requiresProfileSetup: json['requires_profile_setup'] == true ||
          json['requiresProfileSetup'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'userId': userId,
      'is_new_user': isNewUser,
      'requires_profile_setup': requiresProfileSetup,
    };
  }
}

/// Pagination info
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationInfo({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 10,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      totalItems: json['total_items'] ?? json['totalItems'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? json['itemsPerPage'] ?? 10,
      hasNextPage: json['has_next_page'] == true || json['hasNextPage'] == true,
      hasPreviousPage: json['has_previous_page'] == true || json['hasPreviousPage'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final bool success;
  final String? message;
  final List<T> data;
  final PaginationInfo pagination;

  const PaginatedResponse({
    required this.success,
    this.message,
    this.data = const [],
    this.pagination = const PaginationInfo(),
  });

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;
}
