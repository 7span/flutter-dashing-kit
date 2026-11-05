import 'dart:async';
import 'dart:developer';

import 'package:app_core/core/domain/validators/login_validators.dart';
import 'package:app_core/modules/auth/model/auth_request_model.dart';
import 'package:app_core/modules/auth/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required IAuthRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository,
      super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInUserConsentChangedEvent>(_onUserConsentChanged);
    on<SignInSubmitted>(_onSubmitted);
    on<SignInWithGoogleTaped>(_onSignInWithGoogleTaped);
  }

  final IAuthRepository _authenticationRepository;

  void _onEmailChanged(
    SignInEmailChanged event,
    Emitter<SignInState> emit,
  ) {
    final email = EmailValidator.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    final password = PasswordValidator.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  FutureOr<void> _onUserConsentChanged(
    SignInUserConsentChangedEvent event,
    Emitter<SignInState> emit,
  ) {
    emit(state.copyWith(isUserConsent: event.userConsent));
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    final email = EmailValidator.dirty(state.email.value);
    final password = PasswordValidator.dirty(state.password.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      ),
    );
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress, errorMessage: ''));
      final loginEither =
          await _authenticationRepository
              .login(
                AuthRequestModel(
                  email: state.email.value.trim(),
                  password: state.password.value.trim(),
                ),
              )
              .run();

      loginEither.fold(
        (failure) {
          log('failure: $failure');
          emit(
            state.copyWith(
              errorMessage: failure.message,
              status: FormzSubmissionStatus.failure,
            ),
          );
        },
        (success) => emit(
          state.copyWith(status: FormzSubmissionStatus.success),
        ),
      );
    }
  }

  Future<void> _onSignInWithGoogleTaped(
    SignInWithGoogleTaped event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final socialLoginEither =
        await _authenticationRepository
            .socialLogin(requestModel: event.requestModel)
            .run();
    socialLoginEither.fold(
      (error) => emit(
        state.copyWith(
          errorMessage: error.message,
          status: FormzSubmissionStatus.failure,
        ),
      ),
      (result) async {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      },
    );
  }
}
