/// Admin role levels
enum AdminRole {
  owner,
  superAdmin,
  admin,
  moderator,
}

/// Content status for moderation
enum ContentStatus {
  pending,
  approved,
  flagged,
  rejected,
  removed,
}

/// Report type
enum ReportType {
  spam,
  inappropriate,
  fake,
  scam,
  harassment,
  copyright,
  other,
}

/// Report status
enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

/// Entity type being reported/managed
enum EntityType {
  user,
  business,
  event,
  comment,
  review,
  group,
}

/// Business verification status
enum BusinessVerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
  suspended,
}

/// User account status
enum UserAccountStatus {
  active,
  suspended,
  banned,
  deleted,
  pendingVerification,
}

/// Admin user model
class AdminUserModel {
  final String? adminId;
  final String? userId;
  final String? email;
  final String? name;
  final AdminRole role;
  final List<String> permissions;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  AdminUserModel({
    this.adminId,
    this.userId,
    this.email,
    this.name,
    this.role = AdminRole.moderator,
    this.permissions = const [],
    this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      adminId: json['admin_id']?.toString(),
      userId: json['user_id']?.toString(),
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: _parseAdminRole(json['role']),
      permissions: _parsePermissions(json['permissions']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'].toString())
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'user_id': userId,
      'email': email,
      'name': name,
      'role': role.name,
      'permissions': permissions,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isOwner => role == AdminRole.owner;
  bool get isSuperAdmin => role == AdminRole.owner || role == AdminRole.superAdmin;
  bool get canManageAdmins => isSuperAdmin;
  bool get canManageBusinesses => role != AdminRole.moderator || permissions.contains('manage_businesses');
  bool get canManageEvents => true;
  bool get canManageUsers => role != AdminRole.moderator || permissions.contains('manage_users');
  bool get canViewAnalytics => role != AdminRole.moderator || permissions.contains('view_analytics');

  String get roleDisplay {
    switch (role) {
      case AdminRole.owner:
        return 'Owner';
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.moderator:
        return 'Moderator';
    }
  }
}

/// Report model for flagged content
class ContentReportModel {
  final String? reportId;
  final EntityType entityType;
  final String? entityId;
  final ReportType reportType;
  final String? reason;
  final String? details;
  final String? reportedBy;
  final String? reportedByName;
  final ReportStatus status;
  final String? assignedTo;
  final String? resolution;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  // Entity details
  final String? entityName;
  final String? entityImage;
  final String? entityOwnerId;
  final String? entityOwnerName;

  ContentReportModel({
    this.reportId,
    this.entityType = EntityType.event,
    this.entityId,
    this.reportType = ReportType.other,
    this.reason,
    this.details,
    this.reportedBy,
    this.reportedByName,
    this.status = ReportStatus.pending,
    this.assignedTo,
    this.resolution,
    this.createdAt,
    this.resolvedAt,
    this.entityName,
    this.entityImage,
    this.entityOwnerId,
    this.entityOwnerName,
  });

  factory ContentReportModel.fromJson(Map<String, dynamic> json) {
    return ContentReportModel(
      reportId: json['report_id']?.toString(),
      entityType: _parseEntityType(json['entity_type']),
      entityId: json['entity_id']?.toString(),
      reportType: _parseReportType(json['report_type']),
      reason: json['reason'] as String?,
      details: json['details'] as String?,
      reportedBy: json['reported_by']?.toString(),
      reportedByName: json['reported_by_name'] as String?,
      status: _parseReportStatus(json['status']),
      assignedTo: json['assigned_to']?.toString(),
      resolution: json['resolution'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'].toString())
          : null,
      entityName: json['entity_name'] as String?,
      entityImage: json['entity_image'] as String?,
      entityOwnerId: json['entity_owner_id']?.toString(),
      entityOwnerName: json['entity_owner_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'entity_type': entityType.name,
      'entity_id': entityId,
      'report_type': reportType.name,
      'reason': reason,
      'details': details,
      'reported_by': reportedBy,
      'status': status.name,
      'assigned_to': assignedTo,
      'resolution': resolution,
    };
  }

  bool get isPending => status == ReportStatus.pending;
  bool get isResolved => status == ReportStatus.resolved || status == ReportStatus.dismissed;

  String get reportTypeDisplay {
    switch (reportType) {
      case ReportType.spam:
        return 'Spam';
      case ReportType.inappropriate:
        return 'Inappropriate Content';
      case ReportType.fake:
        return 'Fake/Misleading';
      case ReportType.scam:
        return 'Scam';
      case ReportType.harassment:
        return 'Harassment';
      case ReportType.copyright:
        return 'Copyright Violation';
      case ReportType.other:
        return 'Other';
    }
  }

  String get entityTypeDisplay {
    switch (entityType) {
      case EntityType.user:
        return 'User';
      case EntityType.business:
        return 'Business';
      case EntityType.event:
        return 'Event';
      case EntityType.comment:
        return 'Comment';
      case EntityType.review:
        return 'Review';
      case EntityType.group:
        return 'Group';
    }
  }
}

/// Managed business model for admin view
class ManagedBusinessModel {
  final String? businessId;
  final String? name;
  final String? email;
  final String? phone;
  final String? description;
  final String? image;
  final String? ownerId;
  final String? ownerName;
  final String? ownerEmail;
  final BusinessVerificationStatus verificationStatus;
  final bool isActive;
  final bool isFeatured;
  final int eventCount;
  final int followerCount;
  final double rating;
  final int reportCount;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;
  final String? suspensionReason;
  final DateTime? suspendedUntil;

  ManagedBusinessModel({
    this.businessId,
    this.name,
    this.email,
    this.phone,
    this.description,
    this.image,
    this.ownerId,
    this.ownerName,
    this.ownerEmail,
    this.verificationStatus = BusinessVerificationStatus.unverified,
    this.isActive = true,
    this.isFeatured = false,
    this.eventCount = 0,
    this.followerCount = 0,
    this.rating = 0.0,
    this.reportCount = 0,
    this.createdAt,
    this.lastActivityAt,
    this.suspensionReason,
    this.suspendedUntil,
  });

  factory ManagedBusinessModel.fromJson(Map<String, dynamic> json) {
    return ManagedBusinessModel(
      businessId: json['business_id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      ownerId: json['owner_id']?.toString(),
      ownerName: json['owner_name'] as String?,
      ownerEmail: json['owner_email'] as String?,
      verificationStatus: _parseVerificationStatus(json['verification_status']),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      eventCount: json['event_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reportCount: json['report_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.tryParse(json['last_activity_at'].toString())
          : null,
      suspensionReason: json['suspension_reason'] as String?,
      suspendedUntil: json['suspended_until'] != null
          ? DateTime.tryParse(json['suspended_until'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'is_active': isActive,
      'is_featured': isFeatured,
      'verification_status': verificationStatus.name,
    };
  }

  bool get isSuspended => suspendedUntil != null && suspendedUntil!.isAfter(DateTime.now());
  bool get isVerified => verificationStatus == BusinessVerificationStatus.verified;
  bool get hasPendingVerification => verificationStatus == BusinessVerificationStatus.pending;

  String get verificationStatusDisplay {
    switch (verificationStatus) {
      case BusinessVerificationStatus.unverified:
        return 'Unverified';
      case BusinessVerificationStatus.pending:
        return 'Pending Review';
      case BusinessVerificationStatus.verified:
        return 'Verified';
      case BusinessVerificationStatus.rejected:
        return 'Rejected';
      case BusinessVerificationStatus.suspended:
        return 'Suspended';
    }
  }
}

/// Managed event model for admin view
class ManagedEventModel {
  final String? eventId;
  final String? title;
  final String? description;
  final String? image;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? businessId;
  final String? businessName;
  final String? createdBy;
  final String? createdByName;
  final ContentStatus status;
  final bool isActive;
  final bool isFeatured;
  final int attendeeCount;
  final int maxAttendees;
  final int reportCount;
  final DateTime? createdAt;
  final String? removalReason;

  ManagedEventModel({
    this.eventId,
    this.title,
    this.description,
    this.image,
    this.location,
    this.startDate,
    this.endDate,
    this.businessId,
    this.businessName,
    this.createdBy,
    this.createdByName,
    this.status = ContentStatus.approved,
    this.isActive = true,
    this.isFeatured = false,
    this.attendeeCount = 0,
    this.maxAttendees = 0,
    this.reportCount = 0,
    this.createdAt,
    this.removalReason,
  });

  factory ManagedEventModel.fromJson(Map<String, dynamic> json) {
    return ManagedEventModel(
      eventId: json['event_id']?.toString() ?? json['id']?.toString(),
      title: json['title'] as String? ?? json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      location: json['location'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      businessId: json['business_id']?.toString(),
      businessName: json['business_name'] as String?,
      createdBy: json['created_by']?.toString(),
      createdByName: json['created_by_name'] as String?,
      status: _parseContentStatus(json['status']),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      attendeeCount: json['attendee_count'] as int? ?? 0,
      maxAttendees: json['max_attendees'] as int? ?? 0,
      reportCount: json['report_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      removalReason: json['removal_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'description': description,
      'is_active': isActive,
      'is_featured': isFeatured,
      'status': status.name,
    };
  }

  bool get isPending => status == ContentStatus.pending;
  bool get isFlagged => status == ContentStatus.flagged;
  bool get isRemoved => status == ContentStatus.removed;
  bool get isPast => endDate != null && endDate!.isBefore(DateTime.now());

  String get statusDisplay {
    switch (status) {
      case ContentStatus.pending:
        return 'Pending Review';
      case ContentStatus.approved:
        return 'Approved';
      case ContentStatus.flagged:
        return 'Flagged';
      case ContentStatus.rejected:
        return 'Rejected';
      case ContentStatus.removed:
        return 'Removed';
    }
  }
}

/// Managed user model for admin view
class ManagedUserModel {
  final String? userId;
  final String? email;
  final String? name;
  final String? phone;
  final String? profileImage;
  final UserAccountStatus status;
  final bool isVerified;
  final bool isBusinessOwner;
  final int eventCount;
  final int attendedCount;
  final int reportCount;
  final int warningCount;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final String? suspensionReason;
  final DateTime? suspendedUntil;
  final String? banReason;

  ManagedUserModel({
    this.userId,
    this.email,
    this.name,
    this.phone,
    this.profileImage,
    this.status = UserAccountStatus.active,
    this.isVerified = false,
    this.isBusinessOwner = false,
    this.eventCount = 0,
    this.attendedCount = 0,
    this.reportCount = 0,
    this.warningCount = 0,
    this.createdAt,
    this.lastActiveAt,
    this.suspensionReason,
    this.suspendedUntil,
    this.banReason,
  });

  factory ManagedUserModel.fromJson(Map<String, dynamic> json) {
    return ManagedUserModel(
      userId: json['user_id']?.toString() ?? json['id']?.toString(),
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String? ?? json['image'] as String?,
      status: _parseUserStatus(json['status']),
      isVerified: json['is_verified'] as bool? ?? false,
      isBusinessOwner: json['is_business_owner'] as bool? ?? false,
      eventCount: json['event_count'] as int? ?? 0,
      attendedCount: json['attended_count'] as int? ?? 0,
      reportCount: json['report_count'] as int? ?? 0,
      warningCount: json['warning_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.tryParse(json['last_active_at'].toString())
          : null,
      suspensionReason: json['suspension_reason'] as String?,
      suspendedUntil: json['suspended_until'] != null
          ? DateTime.tryParse(json['suspended_until'].toString())
          : null,
      banReason: json['ban_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'status': status.name,
      'is_verified': isVerified,
    };
  }

  bool get isActive => status == UserAccountStatus.active;
  bool get isSuspended => status == UserAccountStatus.suspended;
  bool get isBanned => status == UserAccountStatus.banned;

  String get statusDisplay {
    switch (status) {
      case UserAccountStatus.active:
        return 'Active';
      case UserAccountStatus.suspended:
        return 'Suspended';
      case UserAccountStatus.banned:
        return 'Banned';
      case UserAccountStatus.deleted:
        return 'Deleted';
      case UserAccountStatus.pendingVerification:
        return 'Pending Verification';
    }
  }
}

/// Admin dashboard statistics
class AdminStatsModel {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int totalBusinesses;
  final int verifiedBusinesses;
  final int pendingVerifications;
  final int totalEvents;
  final int activeEvents;
  final int eventsToday;
  final int pendingReports;
  final int resolvedReportsToday;
  final double totalRevenue;
  final double revenueThisMonth;

  AdminStatsModel({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.newUsersToday = 0,
    this.newUsersThisWeek = 0,
    this.totalBusinesses = 0,
    this.verifiedBusinesses = 0,
    this.pendingVerifications = 0,
    this.totalEvents = 0,
    this.activeEvents = 0,
    this.eventsToday = 0,
    this.pendingReports = 0,
    this.resolvedReportsToday = 0,
    this.totalRevenue = 0.0,
    this.revenueThisMonth = 0.0,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      newUsersToday: json['new_users_today'] as int? ?? 0,
      newUsersThisWeek: json['new_users_this_week'] as int? ?? 0,
      totalBusinesses: json['total_businesses'] as int? ?? 0,
      verifiedBusinesses: json['verified_businesses'] as int? ?? 0,
      pendingVerifications: json['pending_verifications'] as int? ?? 0,
      totalEvents: json['total_events'] as int? ?? 0,
      activeEvents: json['active_events'] as int? ?? 0,
      eventsToday: json['events_today'] as int? ?? 0,
      pendingReports: json['pending_reports'] as int? ?? 0,
      resolvedReportsToday: json['resolved_reports_today'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      revenueThisMonth: (json['revenue_this_month'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Admin action log
class AdminActionLogModel {
  final String? logId;
  final String? adminId;
  final String? adminName;
  final String action;
  final EntityType entityType;
  final String? entityId;
  final String? entityName;
  final String? details;
  final DateTime? timestamp;
  final String? ipAddress;

  AdminActionLogModel({
    this.logId,
    this.adminId,
    this.adminName,
    this.action = '',
    this.entityType = EntityType.event,
    this.entityId,
    this.entityName,
    this.details,
    this.timestamp,
    this.ipAddress,
  });

  factory AdminActionLogModel.fromJson(Map<String, dynamic> json) {
    return AdminActionLogModel(
      logId: json['log_id']?.toString(),
      adminId: json['admin_id']?.toString(),
      adminName: json['admin_name'] as String?,
      action: json['action'] as String? ?? '',
      entityType: _parseEntityType(json['entity_type']),
      entityId: json['entity_id']?.toString(),
      entityName: json['entity_name'] as String?,
      details: json['details'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      ipAddress: json['ip_address'] as String?,
    );
  }
}

// Helper parse functions
AdminRole _parseAdminRole(dynamic value) {
  if (value == null) return AdminRole.moderator;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'owner':
        return AdminRole.owner;
      case 'superadmin':
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      default:
        return AdminRole.moderator;
    }
  }
  return AdminRole.moderator;
}

List<String> _parsePermissions(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

EntityType _parseEntityType(dynamic value) {
  if (value == null) return EntityType.event;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'user':
        return EntityType.user;
      case 'business':
        return EntityType.business;
      case 'comment':
        return EntityType.comment;
      case 'review':
        return EntityType.review;
      case 'group':
        return EntityType.group;
      default:
        return EntityType.event;
    }
  }
  return EntityType.event;
}

ReportType _parseReportType(dynamic value) {
  if (value == null) return ReportType.other;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'spam':
        return ReportType.spam;
      case 'inappropriate':
        return ReportType.inappropriate;
      case 'fake':
        return ReportType.fake;
      case 'scam':
        return ReportType.scam;
      case 'harassment':
        return ReportType.harassment;
      case 'copyright':
        return ReportType.copyright;
      default:
        return ReportType.other;
    }
  }
  return ReportType.other;
}

ReportStatus _parseReportStatus(dynamic value) {
  if (value == null) return ReportStatus.pending;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'under_review':
      case 'underreview':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
  return ReportStatus.pending;
}

ContentStatus _parseContentStatus(dynamic value) {
  if (value == null) return ContentStatus.approved;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ContentStatus.pending;
      case 'flagged':
        return ContentStatus.flagged;
      case 'rejected':
        return ContentStatus.rejected;
      case 'removed':
        return ContentStatus.removed;
      default:
        return ContentStatus.approved;
    }
  }
  return ContentStatus.approved;
}

BusinessVerificationStatus _parseVerificationStatus(dynamic value) {
  if (value == null) return BusinessVerificationStatus.unverified;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending':
        return BusinessVerificationStatus.pending;
      case 'verified':
        return BusinessVerificationStatus.verified;
      case 'rejected':
        return BusinessVerificationStatus.rejected;
      case 'suspended':
        return BusinessVerificationStatus.suspended;
      default:
        return BusinessVerificationStatus.unverified;
    }
  }
  return BusinessVerificationStatus.unverified;
}

UserAccountStatus _parseUserStatus(dynamic value) {
  if (value == null) return UserAccountStatus.active;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'suspended':
        return UserAccountStatus.suspended;
      case 'banned':
        return UserAccountStatus.banned;
      case 'deleted':
        return UserAccountStatus.deleted;
      case 'pending':
      case 'pending_verification':
        return UserAccountStatus.pendingVerification;
      default:
        return UserAccountStatus.active;
    }
  }
  return UserAccountStatus.active;
}
