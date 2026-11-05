import 'dart:async';

import 'package:app_core/core/domain/validators/login_validators.dart';
import 'package:app_core/modules/auth/model/auth_request_model.dart';
import 'package:app_core/modules/auth/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required IAuthRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository,
      super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  final IAuthRepository _authenticationRepository;

  void _onEmailChanged(ForgotPasswordEmailChanged event, Emitter<ForgotPasswordState> emit) {
    final email = EmailValidator.dirty(event.email.trim());
    emit(state.copyWith(email: email, isValid: Formz.validate([email])));
  }

  Future<Unit> _onSubmitted(ForgotPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    final email = EmailValidator.dirty(state.email.value);
    emit(state.copyWith(email: email, isValid: Formz.validate([email])));
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      final result =
          await _authenticationRepository.forgotPassword(AuthRequestModel.forgotPassword(email: state.email.value)).run();
      result.fold(
        (failure) => emit(state.copyWith(status: FormzSubmissionStatus.failure, errorMessage: failure.message)),
        (success) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
      );
    }
    return unit;
  }
}
