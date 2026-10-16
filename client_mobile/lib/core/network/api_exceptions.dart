import 'package:dio/dio.dart';

/// Base class for all typed ARISE API errors.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  @override
  String toString() => 'ApiException [$code] ($statusCode): $message';

  /// Maps a [DioException] to a specialized, strongly-typed [ApiException].
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiTimeoutException(
          message: 'Connection timed out. The System core took too long to respond.',
          statusCode: error.response?.statusCode,
          details: error.message,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Uplink unavailable. Please check your network connection.',
        );

      case DioExceptionType.badResponse:
        return _parseBadResponse(error.response);

      case DioExceptionType.cancel:
        return const RequestCancelledException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.badCertificate:
        return const SecurityCertificateException(
          message: 'Secure SSL/TLS certificate verification failed.',
        );

      case DioExceptionType.unknown:
      default:
        if (error.error is ApiException) {
          return error.error as ApiException;
        }
        return UnknownApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          statusCode: error.response?.statusCode,
          details: error.error,
        );
    }
  }

  static ApiException _parseBadResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 500;
    final data = response?.data;

    String? code;
    String message = 'An unexpected server error occurred';
    dynamic details;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
        final err = data['error'] as Map<String, dynamic>;
        code = err['code']?.toString();
        message = err['message']?.toString() ?? message;
        details = err['details'];
      } else if (data.containsKey('message')) {
        message = data['message']?.toString() ?? message;
        code = data['code']?.toString();
        details = data['details'];
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    if (status == 401) {
      if (code == 'TOKEN_REUSE_DETECTED') {
        return TokenReuseException(
          message: message,
          details: details,
        );
      }
      return UnauthorizedException(
        message: message,
        code: code ?? 'UNAUTHORIZED',
        details: details,
      );
    }

    if (status == 403) {
      return ForbiddenException(
        message: message,
        code: code ?? 'FORBIDDEN',
        details: details,
      );
    }

    if (status == 404) {
      return NotFoundException(
        message: message,
        code: code ?? 'NOT_FOUND',
        details: details,
      );
    }

    if (status == 409) {
      return ConflictException(
        message: message,
        code: code ?? 'CONFLICT',
        details: details,
      );
    }

    if (status == 400 || status == 422) {
      return ValidationException(
        message: message,
        code: code ?? 'VALIDATION_ERROR',
        details: details,
      );
    }

    if (status == 429 || code == 'AI_DAILY_QUOTA_EXCEEDED') {
      return QuotaExceededException(
        message: message,
        code: code ?? 'AI_DAILY_QUOTA_EXCEEDED',
        details: details,
      );
    }

    if (status >= 500 && status < 600) {
      return ServerException(
        message: message,
        statusCode: status,
        code: code ?? 'INTERNAL_SERVER_ERROR',
        details: details,
      );
    }

    return UnknownApiException(
      message: message,
      statusCode: status,
      code: code ?? 'UNKNOWN_ERROR',
      details: details,
    );
  }
}

/// Thrown on 429 Too Many Requests / Quota Exceeded (§10.5).
class QuotaExceededException extends ApiException {
  const QuotaExceededException({
    required super.message,
    super.statusCode = 429,
    super.code = 'AI_DAILY_QUOTA_EXCEEDED',
    super.details,
  });
}

/// Thrown when device has no internet access or socket connection fails.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Uplink unavailable. Please check your network connection.',
    super.statusCode,
    super.code = 'NETWORK_UNAVAILABLE',
    super.details,
  });
}

/// Thrown when connection, send, or receive timeout occurs.
class ApiTimeoutException extends ApiException {
  const ApiTimeoutException({
    super.message = 'System request timed out. Please try again.',
    super.statusCode,
    super.code = 'TIMEOUT',
    super.details,
  });
}

/// Thrown on 401 Unauthorized (invalid credentials, expired token).
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    required super.message,
    super.statusCode = 401,
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}

/// Thrown on AC-AUTH-004 token reuse detection.
class TokenReuseException extends UnauthorizedException {
  const TokenReuseException({
    super.message = 'Token reuse detected. All active sessions have been revoked.',
    super.statusCode = 401,
    super.code = 'TOKEN_REUSE_DETECTED',
    super.details,
  });
}

/// Thrown on 403 Forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.message,
    super.statusCode = 403,
    super.code = 'FORBIDDEN',
    super.details,
  });
}

/// Thrown on 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException({
    required super.message,
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
    super.details,
  });
}

/// Thrown on 409 Conflict (e.g., USER_EXISTS during registration).
class ConflictException extends ApiException {
  const ConflictException({
    required super.message,
    super.statusCode = 409,
    super.code = 'USER_EXISTS',
    super.details,
  });
}

/// Thrown on 400/422 Bad Request / Schema Validation failures.
class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.statusCode = 400,
    super.code = 'VALIDATION_ERROR',
    super.details,
  });

  /// Extracts structured field errors if available.
  List<String> get validationErrors {
    if (details is List) {
      return (details as List).map((e) {
        if (e is Map && e.containsKey('message')) {
          return e['message'].toString();
        }
        return e.toString();
      }).toList();
    }
    return [message];
  }
}

/// Thrown on 5xx Server Errors.
class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.statusCode = 500,
    super.code = 'SERVER_ERROR',
    super.details,
  });
}

/// Thrown when a request was manually cancelled.
class RequestCancelledException extends ApiException {
  const RequestCancelledException({
    super.message = 'Request was cancelled.',
    super.statusCode,
    super.code = 'REQUEST_CANCELLED',
    super.details,
  });
}

/// Thrown when TLS certificate validation fails.
class SecurityCertificateException extends ApiException {
  const SecurityCertificateException({
    super.message = 'Security certificate verification failed.',
    super.statusCode,
    super.code = 'BAD_CERTIFICATE',
    super.details,
  });
}

/// Fallback for unrecognized error responses.
class UnknownApiException extends ApiException {
  const UnknownApiException({
    required super.message,
    super.statusCode,
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}
