class AdminContributeModel {
  final String id;
  final String userId;
  final String userEmail;
  final String content;
  final String status;
  final String? response;
  final DateTime createdAt;

  AdminContributeModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.content,
    required this.status,
    this.response,
    required this.createdAt,
  });

  factory AdminContributeModel.fromJson(Map<String, dynamic> json) {
    // Xử lý an toàn khi join không có '!inner' (dữ liệu có thể null)
    dynamic userData = json['users'];
    String email = 'Người dùng ẩn danh'; // Giá trị mặc định nếu không lấy được email

    if (userData != null) {
      if (userData is Map) {
        email = userData['email']?.toString() ?? 'Người dùng ẩn danh';
      } else if (userData is List && userData.isNotEmpty) {
        email = userData[0]['email']?.toString() ?? 'Người dùng ẩn danh';
      }
    }

    return AdminContributeModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userEmail: email,
      content: json['content'] ?? '',
      status: json['status'] ?? 'pending',
      response: json['response'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
