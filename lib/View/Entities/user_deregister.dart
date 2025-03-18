class UserDeregister {
  final bool success;
  final String message;
  final String status;
  final int code;

  UserDeregister({
    required this.success,
    required this.message,
    required this.status,
    required this.code,
  });

  factory UserDeregister.fromJson(Map<String, dynamic> json) => UserDeregister(
    success: (json['status'] == "ok" && json['code'] == 200),
    message: json['message'],
    status: json['status'],
    code: json['code'],
  );
}

// {
//     "message": "Deregistered",
//     "status": "ok",
//     "code": 200
// }