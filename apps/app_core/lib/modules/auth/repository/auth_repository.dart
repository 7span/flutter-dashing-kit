import 'package:api_client/api_client.dart';
import 'package:app_core/app/config/api_endpoints.dart';
import 'package:app_core/app/helpers/injection.dart';
import 'package:app_core/core/data/models/user_model.dart';
import 'package:app_core/core/data/services/hive.service.dart';
import 'package:app_core/core/data/services/logout_service.dart';
import 'package:app_core/modules/auth/model/auth_request_model.dart';
import 'package:app_core/modules/auth/model/auth_response_model.dart';
import 'package:app_notification_service/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// This repository contains the contract for login and logout function
abstract interface class IAuthRepository {
  TaskEither<Failure, Unit> login(AuthRequestModel authRequestModel);

  TaskEither<Failure, Unit> signup(AuthRequestModel authRequestModel);

  TaskEither<Failure, bool> logout();

  TaskEither<Failure, Unit> forgotPassword(AuthRequestModel authRequestModel);

  TaskEither<Failure, Unit> socialLogin({required AuthRequestModel requestModel});

  TaskEither<Failure, AuthResponseModel> verifyOTP(AuthRequestModel authRequestModel);
}

// ignore: comment_references
/// This repository connects with [IAuthService] for setting the data of the user
/// that is given by the API Response
class AuthRepository implements IAuthRepository {
  const AuthRepository();

  @override
  TaskEither<Failure, Unit> login(AuthRequestModel authRequestModel) => makeLoginRequest(authRequestModel)
      .chainEither(RepositoryUtils.checkStatusCode)
      .chainEither(
        (response) => RepositoryUtils.mapToModel(() {
          return AuthResponseModel.fromMap(
            response.data as Map<String, dynamic>,
            defaultEmail: authRequestModel.email,
          );
        }),
      )
      .flatMap(saveUserToLocal);

  TaskEither<Failure, Response> makeLoginRequest(AuthRequestModel authRequestModel) => userApiClient.request(
    requestType: RequestType.post,
    path: ApiEndpoints.login,
    body: authRequestModel.toMap(),
    options: Options(headers: {'x-api-key': 'reqres-free-v1', 'Content-Type': 'application/json'}),
  );

  TaskEither<Failure, Unit> saveUserToLocal(AuthResponseModel authResponseModel) => getIt<IHiveService>().setUserData(
    UserModel(name: 'user name', email: 'user email', profilePicUrl: '', id: int.parse(authResponseModel.id)),
  );

  @override
  TaskEither<Failure, Unit> signup(AuthRequestModel authRequestModel) => makeSignUpRequest(authRequestModel)
      .chainEither(RepositoryUtils.checkStatusCode)
      .chainEither(
        (r) => RepositoryUtils.mapToModel(() {
          /// as we are not getting proper response from mock api, we are directly returning AuthResponseModel
          /// response : { "id": 4,"token": "QpwL5tke4Pnpja7X4" }
          /// uncomment this code while api call integration
          //   return AuthResponseModel.fromMap(
          //   r.data as Map<String, dynamic>,
          // );
          return AuthResponseModel(email: 'eve.holt@reqres.in', id: (r.data as Map<String, dynamic>)['id'].toString());
        }),
      )
      .flatMap(saveUserToLocal);

  TaskEither<Failure, Response> makeSignUpRequest(AuthRequestModel authRequestModel) => userApiClient.request(
    requestType: RequestType.post,
    path: ApiEndpoints.signup,
    body: authRequestModel.toMap(),
    options: Options(headers: {'Content-Type': 'application/json'}),
  );

  TaskEither<Failure, Unit> _clearHiveData() =>
      TaskEither.tryCatch(() => getIt<LogoutService>().logout().run(), (error, stackTrace) => APIFailure());

  @override
  TaskEither<Failure, bool> logout() => makeLogoutRequest().flatMap(
    (_) => _clearHiveData().flatMap((r) {
      return TaskEither<Failure, bool>.of(true);
    }),
  );

  TaskEither<Failure, String> _getNotificationId() => TaskEither.tryCatch(() {
    return getIt<NotificationServiceInterface>().getNotificationSubscriptionId();
  }, APIFailure.new);

  TaskEither<Failure, Response> makeLogoutRequest() => _getNotificationId().flatMap(
    (playerID) => userApiClient.request(
      requestType: RequestType.delete,

      /// You have to pass [playerID] as query parameter, while calling logout api
      /// Mock api returns different id in response of authentication everytime.
      /// Since Hive will store those same different ids, this api will not work.
      path: ApiEndpoints.logout,
    ),
  );

  @override
  TaskEither<Failure, Unit> socialLogin({required AuthRequestModel requestModel}) => makeSocialLoginRequest(
        requestModel: requestModel,
      )
      .chainEither(RepositoryUtils.checkStatusCode)
      .chainEither(
        (response) =>
            RepositoryUtils.mapToModel<AuthResponseModel>(() => AuthResponseModel.fromMap(response.data as Map<String, dynamic>)),
      )
      .flatMap(saveUserToLocal);

  TaskEither<Failure, Response> makeSocialLoginRequest({required AuthRequestModel requestModel}) {
    return userApiClient.request(
      requestType: RequestType.post,
      path: ApiEndpoints.socialLogin,
      body: requestModel.toSocialSignInMap(),
    );
  }

  @override
  TaskEither<Failure, Unit> forgotPassword(AuthRequestModel authRequestModel) => makeForgotPasswordRequest(authRequestModel)
      .chainEither(RepositoryUtils.checkStatusCode)
      .chainEither(
        (response) => RepositoryUtils.mapToModel(() {
          return response.data;
        }),
      )
      .map((_) => unit);

  TaskEither<Failure, Response> makeForgotPasswordRequest(AuthRequestModel authRequestModel) => userApiClient.request(
    requestType: RequestType.post,
    path: ApiEndpoints.forgotPassword,
    body: authRequestModel.toForgotPasswordMap(),
    options: Options(headers: {'x-api-key': 'reqres-free-v1', 'Content-Type': 'application/json'}),
  );

  @override
  TaskEither<Failure, AuthResponseModel> verifyOTP(AuthRequestModel authRequestModel) => makeVerifyOTPRequest(authRequestModel)
      .chainEither(RepositoryUtils.checkStatusCode)
      .chainEither(
        (response) => RepositoryUtils.mapToModel(() {
          return AuthResponseModel.fromMap(response.data as Map<String, dynamic>);
        }),
      );

  TaskEither<Failure, Response> makeVerifyOTPRequest(AuthRequestModel authRequestModel) => userApiClient.request(
    requestType: RequestType.post,
    path: ApiEndpoints.verifyOTP,
    body: authRequestModel.toVerifyOTPMap(),
    options: Options(headers: {'Content-Type': 'application/json'}),
  );
}
