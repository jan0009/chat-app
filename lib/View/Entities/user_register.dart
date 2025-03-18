class UserRegister {
  final bool success;
  final String message;
  final String token;
  final String hash;
  final String status;
  final int code;

  UserRegister({
    required this.success,
    required this.message,
    required this.token,
    required this.hash,
    required this.status,
    required this.code,
  });

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    bool isSuccess = (json['status'] == "ok" && json['code'] == 200);

    return UserRegister(
      success: isSuccess,
      message: json['message'],
      status: json['status'],
      code: json['code'],
      token: isSuccess ? json['token'] : null,
      hash: isSuccess ? json['hash'] : null,
    );
  }
}
// First Registration

// {
//     "message": "Registered",
//     "token": "EEiBVROJ",
//     "hash": "0rqgmIFi",
//     "status": "ok",
//     "code": 200
// }

// Already Registered

// {
//     "status": "error",
//     "message": "User 'jadrit00' already exists",
//     "code": 452
// }
