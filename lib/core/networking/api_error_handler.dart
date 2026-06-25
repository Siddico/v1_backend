import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

enum DataSource {
  success,
  noContent,
  badRequest,
  forbidden,
  unauthorized,
  notFound,
  internalServerError,
  connectTimeout,
  cancel,
  receiveTimeout,
  sendTimeout,
  cacheError,
  noInternetConnection,
  defaultError,
}

class ErrorHandler implements Exception {
  late ErrorMessageModel errorMessage;

  ErrorHandler.handle(dynamic error, BuildContext context) {
    if (error is DioException) {
      errorMessage = _handleError(error, context);
    } else {
      errorMessage = DataSource.defaultError.getFailure(context);
    }
  }
}

ErrorMessageModel _handleError(DioException error, BuildContext context) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.connectTimeout.getFailure(context);
    case DioExceptionType.sendTimeout:
      return DataSource.sendTimeout.getFailure(context);
    case DioExceptionType.receiveTimeout:
      return DataSource.receiveTimeout.getFailure(context);
    case DioExceptionType.badResponse:
      if (error.response != null && error.response?.statusCode != null && error.response?.statusMessage != null) {
        // Here we can parse Laravel's custom validation errors when Postman collection is ready
        return ErrorMessageModel(
          code: error.response?.statusCode ?? 0,
          message: error.response?.data?['message'] ?? error.response?.statusMessage ?? '',
        );
      } else {
        return DataSource.defaultError.getFailure(context);
      }
    case DioExceptionType.cancel:
      return DataSource.cancel.getFailure(context);
    case DioExceptionType.unknown:
    case DioExceptionType.connectionError:
      return DataSource.noInternetConnection.getFailure(context);
    case DioExceptionType.badCertificate:
      return DataSource.defaultError.getFailure(context);
  }
}

extension DataSourceExtension on DataSource {
  ErrorMessageModel getFailure(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Safely extract localized strings or fallback to defaults
    String trans(String key, String fallback) {
      // Assuming localizedValues in AppLocalizations uses the key, but we'll fetch from the map directly or add a getter in AppLocalizations.
      // Since AppLocalizations.of(context) might not expose a direct translate method if not set up, 
      // we'll format this nicely so it works out of the box once we update app_localizations.dart.
      return localizations?.translate(key) ?? fallback;
    }

    switch (this) {
      case DataSource.badRequest:
        return ErrorMessageModel(code: 400, message: trans('bad_request_error', 'Bad request, try again later'));
      case DataSource.forbidden:
        return ErrorMessageModel(code: 403, message: trans('forbidden_error', 'Forbidden request, try again later'));
      case DataSource.unauthorized:
        return ErrorMessageModel(code: 401, message: trans('unauthorized_error', 'User is unauthorized, try again later'));
      case DataSource.notFound:
        return ErrorMessageModel(code: 404, message: trans('not_found_error', 'Not found, try again later'));
      case DataSource.internalServerError:
        return ErrorMessageModel(code: 500, message: trans('internal_server_error', 'Some thing went wrong, try again later'));
      case DataSource.connectTimeout:
        return ErrorMessageModel(code: 0, message: trans('timeout_error', 'Timeout, try again later'));
      case DataSource.cancel:
        return ErrorMessageModel(code: 0, message: trans('default_error', 'Request was cancelled, try again later'));
      case DataSource.receiveTimeout:
        return ErrorMessageModel(code: 0, message: trans('timeout_error', 'Timeout, try again later'));
      case DataSource.sendTimeout:
        return ErrorMessageModel(code: 0, message: trans('timeout_error', 'Timeout, try again later'));
      case DataSource.cacheError:
        return ErrorMessageModel(code: 0, message: trans('cache_error', 'Cache error, try again later'));
      case DataSource.noInternetConnection:
        return ErrorMessageModel(code: 0, message: trans('no_internet_error', 'Please check your internet connection'));
      case DataSource.defaultError:
        return ErrorMessageModel(code: 0, message: trans('default_error', 'Some thing went wrong, try again later'));
      default:
        return ErrorMessageModel(code: 0, message: trans('default_error', 'Some thing went wrong, try again later'));
    }
  }
}

class ErrorMessageModel {
  final int code;
  final String message;

  ErrorMessageModel({required this.code, required this.message});
}
