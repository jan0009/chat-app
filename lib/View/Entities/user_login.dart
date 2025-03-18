class UserLogin {
  final bool success;
  final String message;
  final String token;
  final String hash;

  UserLogin({
    required this.success,
    required this.message,
    required this.token,
    required this.hash,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
    success: (json['status'] == "ok" && json['code'] == 200),
    message: json['message'],
    token: json['token'],
    hash: json['hash'],
  );
}
