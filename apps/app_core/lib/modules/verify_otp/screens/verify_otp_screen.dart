import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:app_core/app/routes/app_router.dart';
import 'package:app_core/core/presentation/widgets/app_snackbar.dart';
import 'package:app_core/modules/auth/repository/auth_repository.dart';
import 'package:app_core/modules/verify_otp/bloc/verify_otp_bloc.dart';
import 'package:app_core/modules/verify_otp/bloc/verify_otp_state.dart';
import 'package:app_translations/app_translations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class VerifyOTPScreen extends StatefulWidget implements AutoRouteWrapper {
  const VerifyOTPScreen({required this.emailAddress, super.key});

  final String emailAddress;

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (context) => const AuthRepository(),
      child: BlocProvider(
        create: (context) => VerifyOTPBloc(RepositoryProvider.of<AuthRepository>(context))..add(SetEmailEvent(emailAddress)),
        child: this,
      ),
    );
  }
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: CustomAppBar(
        backgroundColor: context.colorScheme.white,
        automaticallyImplyLeading: true,
        title: context.t.verify_otp,
      ),
      body: BlocConsumer<VerifyOTPBloc, VerifyOTPState>(
        listener: (context, state) {
          if (state.verifyOtpStatus == ApiStatus.loaded && state.otp.value == '222222') {
            showAppSnackbar(context, 'OTP verified successfully!');
            unawaited(context.replaceRoute(const ChangePasswordRoute()));
          } else if (state.verifyOtpStatus == ApiStatus.error) {
            showAppSnackbar(context, 'Invalid OTP', type: SnackbarType.failed);
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(Insets.small12),
            children: [
              VSpace.large24(),
              SlideAndFadeAnimationWrapper(delay: 100, child: Center(child: Assets.images.logo.image(width: 100))),
              VSpace.large24(),
              SlideAndFadeAnimationWrapper(
                delay: 200,
                child: Center(child: AppText.xsSemiBold(text: context.t.welcome, fontSize: 16)),
              ),
              VSpace.large24(),
              AppTextField(initialValue: widget.emailAddress, label: context.t.email, isReadOnly: true),
              VSpace.medium16(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(Insets.small12),
                  child: AppText.sSemiBold(text: context.t.enter_otp),
                ),
              ),
              VSpace.small12(),
              AppOtpInput(
                errorText: state.otp.error != null ? context.t.pin_incorrect : null,
                onChanged: (value) {
                  context.read<VerifyOTPBloc>().add(VerifyOTPChanged(value));
                },
              ),

              VSpace.xsmall8(),
              if (state.isTimerRunning)
                Center(
                  child: AppTimer(
                    seconds: 30,
                    onFinished: () {
                      context.read<VerifyOTPBloc>().add(const TimerFinishedEvent());
                    },
                  ),
                ),
              VSpace.small12(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.xsRegular(color: context.colorScheme.black, text: context.t.did_not_receive_otp),
                  AppButton(
                    text: context.t.resend_otp,
                    buttonType: ButtonType.text,
                    textColor: context.colorScheme.primary400,
                    onPressed:
                        state.isTimerRunning
                            ? null
                            : () {
                              FocusScope.of(context).unfocus();
                              context.read<VerifyOTPBloc>().add(const ResendEmailEvent());
                            },
                  ),
                  HSpace.xsmall8(),
                ],
              ),
              VSpace.large24(),
              AppButton(
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: Insets.large24),
                text: context.t.verify_otp,
                isLoading: state.verifyOtpStatus == ApiStatus.loading,
                onPressed: () => context.read<VerifyOTPBloc>().add(const VerifyButtonPressed()),
              ),
            ],
          );
        },
      ),
    );
  }
}
