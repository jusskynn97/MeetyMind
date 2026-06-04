class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ServerException(message: $message, statusCode: $statusCode, data: $data)';
  }
}
