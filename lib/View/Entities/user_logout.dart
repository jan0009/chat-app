// {
//     "message": "Logged out",
//     "status": "ok",
//     "code": 200
// }

class UserLogout {
  final bool success;
  final String message;
  final String status;
  final int code;

  UserLogout({
    required this.success,
    required this.message,
    required this.status,
    required this.code,
  });

  factory UserLogout.fromJson(Map<String, dynamic> json) => UserLogout(
    success: (json['status'] == "ok" && json['code'] == 200),
    message: json['message'],
    status: json['status'],
    code: json['code'],
  );
}
