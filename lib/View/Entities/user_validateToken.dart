class ValidateToken {
  final bool success;
  final String message;
  final String status;
  final int code;

  ValidateToken({
    required this.success,
    required this.message,
    required this.status,
    required this.code,
  });

  factory ValidateToken.fromJson(Map<String, dynamic> json) => ValidateToken(
    success: (json['status'] == "ok" && json['code'] == 200),
    message: json['message'],
    status: json['status'],
    code: json['code'],
  );
}

// Api Responses

// Invalide Token 
// {
//     "status": "error",
//     "message": "Invalid token",
//     "code": 456
// }

// Valide Token 
// {
//     "message": "Token valid",
//     "status": "ok",
//     "code": 200
// }


