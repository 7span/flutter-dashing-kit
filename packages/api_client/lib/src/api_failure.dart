import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:graphql/client.dart' show OperationException;

/// Here, we're creating an abstract class for Faliure, Because
/// We can swap any kind of implementation that we want while
/// passing the Sub Failure class or while testing
/// [APIFailure] -> Failure while Calling the API
/// [RequestMakingFaliure] -> Failure when creating the request
/// [ResponseValidationFailure] -> Failure when validating the response
/// [ModelConversionFailure] -> Failure when converting the model to Dart Object
sealed class Failure {
  Failure();

  String get message;
}

/// This failure represents that there's some issue
/// in either calling an API or while there's something
/// happened on the backend side
class APIFailure extends Failure {
  APIFailure([this.error, this.stackTrace]) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message {
    if (error is Response) {
      final data = (error as Response).data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            'An error occurred while calling the API';
      }
      return 'An error occurred while calling the API';
    } else if (error is DioException) {
      final dioException = error as DioException;
      final data = dioException.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            dioException.message ??
            'An error occurred while calling the API';
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
      return dioException.message ?? 'An error occurred while calling the API';
    } else {
      return 'An error occurred while calling the API';
    }
  }

  @override
  String toString() {
    return 'APIFailure{error: $error, stackTrace: $stackTrace}';
  }
}

/// This failure represents that there's some problem in creating the request
class RequestMakingFaliure extends Failure {
  RequestMakingFaliure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message =>
      'There is some error in preparing the request';
}

/// This failure represents that there's some problem in validating the response
class ResponseValidationFailure extends Failure {
  ResponseValidationFailure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message =>
      error is OperationException
          ? (error as OperationException).graphqlErrors[0].message
          : 'There is some error in validating the API response';
}

/// This failure represents that there's some problem in parsing the
/// json data into dart model
class ModelConversionFailure extends Failure {
  ModelConversionFailure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message =>
      'The API data could not be parsed into the model';
}

/// This failure is used when we're not able to write the userdata into the database
class UserSaveFailure extends Failure {
  UserSaveFailure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message => "There's an issue in saving the data";
}

class UserTokenSaveFailure extends Failure {
  UserTokenSaveFailure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message => "There's an issue in saving the token";
}

class HiveFailure extends Failure {
  HiveFailure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message => "There's an issue in Hive";
}

class UrlLaunchingFailure extends Failure {
  UrlLaunchingFailure({this.error, this.stackTrace}) {
    log(stackTrace.toString());
    log(error.toString());
  }

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message => "Could not launch the URL";
}
