sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.details});
  final String message;
  final int? statusCode;
  final Object? details;
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.details}) : super(statusCode: 401);
}
final class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.details}) : super(statusCode: 403);
}
final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.details}) : super(statusCode: 404);
}
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.details}) : super(statusCode: 422);
}
final class RateLimitException extends AppException {
  const RateLimitException(super.message, {super.details}) : super(statusCode: 429);
}
final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.details});
}
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.details});
}
final class UnexpectedResponseException extends AppException {
  const UnexpectedResponseException(super.message, {super.statusCode, super.details});
}
