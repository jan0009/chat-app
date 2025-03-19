class UserLogin {
  final bool success;
  final String message;
  final String token;
  final String hash;
  final String status;
  final int code;

  UserLogin({
    required this.success,
    required this.message,
    required this.token,
    required this.hash,
    required this.status,
    required this.code,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json){
    bool isSuccess = (json['status'] == "ok" && json['code'] == 200);

    return UserLogin(
      success: isSuccess,
      message: json['message'],
      status: json['status'],
      code: json['code'],
      token: isSuccess ? json['token'] : null,  
      hash: isSuccess ? json['hash'] : null,
    );
}
}

// {
//     "message": "Logged in",
//     "token": "VbdLtSyV",
//     "hash": "27vggjYB",
//     "status": "ok",
//     "code": 200
// }

// {
//     "status": "error",
//     "message": "Wrong password: '1'",
//     "code": 455
// }