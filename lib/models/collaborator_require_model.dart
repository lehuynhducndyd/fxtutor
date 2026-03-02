class CollaboratorRequireModel {
  final String id;
  final String userId;
  final String userEmail;
  final String status;
  final DateTime createdAt;

  CollaboratorRequireModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.status,
    required this.createdAt,
  });

  factory CollaboratorRequireModel.fromJson(Map<String, dynamic> json) {
    // Xử lý Left Join lấy email an toàn
    dynamic userData = json['users'];
    String email = 'Người dùng ẩn danh';
    if (userData != null) {
      if (userData is Map)
        email = userData['email']?.toString() ?? email;
      else if (userData is List && userData.isNotEmpty)
        email = userData[0]['email']?.toString() ?? email;
    }

    return CollaboratorRequireModel(
      id: json['id'],
      userId: json['user_id'],
      userEmail: email,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
