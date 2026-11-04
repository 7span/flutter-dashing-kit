import 'dart:async';
import 'dart:io';

import 'package:app_core/app/routes/app_router.dart';
import 'package:app_core/core/data/services/apple_auth_helper.dart';
import 'package:app_core/core/data/services/google_auth_helper.dart';
import 'package:app_core/core/presentation/widgets/app_snackbar.dart';
import 'package:app_core/modules/auth/model/auth_request_model.dart';
import 'package:app_core/modules/auth/repository/auth_repository.dart';
import 'package:app_core/modules/auth/sign_in/bloc/sign_in_bloc.dart';
import 'package:app_translations/app_translations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SignInPage extends StatelessWidget implements AutoRouteWrapper {
  const SignInPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => const AuthRepository())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SignInBloc(authenticationRepository: RepositoryProvider.of<AuthRepository>(context))),
        ],
        child: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocListener<SignInBloc, SignInState>(
        listenWhen: (previous, current) => previous.status != current.status,

        listener: (context, state) async {
          if (state.status.isFailure) {
            showAppSnackbar(context, state.errorMessage, type: SnackbarType.failed);
          } else if (state.status.isSuccess) {
            showAppSnackbar(context, context.t.sign_in_successful);
            await context.replaceRoute(const BottomNavigationBarRoute());
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Insets.large24),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VSpace.xxxxlarge80(),
                VSpace.large24(),
                const SlideAndFadeAnimationWrapper(delay: 100, child: Center(child: FlutterLogo(size: 100))),
                VSpace.xxlarge40(),
                VSpace.large24(),
                SlideAndFadeAnimationWrapper(delay: 200, child: AppText.XL(text: context.t.sign_in)),
                VSpace.large24(),
                SlideAndFadeAnimationWrapper(delay: 300, child: _EmailInput()),
                VSpace.large24(),
                SlideAndFadeAnimationWrapper(delay: 400, child: _PasswordInput()),
                VSpace.large24(),
                AnimatedGestureDetector(
                  onTap: () async {
                    await context.pushRoute(const ForgotPasswordRoute());
                  },
                  child: SlideAndFadeAnimationWrapper(
                    delay: 200,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: AppText.regular10(
                        fontSize: 14,
                        text: context.t.forgot_password,
                        color: context.colorScheme.primary400,
                      ),
                    ),
                  ),
                ),
                VSpace.large24(),
                SlideAndFadeAnimationWrapper(delay: 400, child: _UserConsentWidget()),
                VSpace.xxlarge40(),
                const SlideAndFadeAnimationWrapper(delay: 500, child: _LoginButton()),
                VSpace.large24(),
                const SlideAndFadeAnimationWrapper(delay: 600, child: _CreateAccountButton()),
                VSpace.large24(),
                const SlideAndFadeAnimationWrapper(delay: 600, child: _ContinueWithGoogleButton()),
                VSpace.large24(),
                if (Platform.isIOS) const SlideAndFadeAnimationWrapper(delay: 600, child: _ContinueWithAppleButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return AppTextField(
          initialValue: state.email.value,
          label: context.t.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (email) => context.read<SignInBloc>().add(SignInEmailChanged(email)),
          errorText: state.email.displayError != null ? context.t.common_validation_email : null,
          autofillHints: const [AutofillHints.email],
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return AppTextField.password(
          initialValue: state.password.value,
          label: context.t.password,
          textInputAction: TextInputAction.done,
          onChanged: (password) => context.read<SignInBloc>().add(SignInPasswordChanged(password)),
          errorText: state.password.displayError != null ? context.t.common_validation_password : null,
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }
}

class _UserConsentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignInBloc, SignInState, bool>(
      selector: (state) => state.isUserConsent,
      builder: (context, isUserConsent) {
        return UserConsentWidget(
          value: isUserConsent,
          onCheckBoxValueChanged: (userConsent) {
            context.read<SignInBloc>().add(SignInUserConsentChangedEvent(userConsent: userConsent ?? false));
          },
          onTermsAndConditionTap:
              () => launchUrl(
                Uri.parse(
                  // TODO(nikunj-p-7span): Change your Terms and Condition link here
                  'https://codelabs-preview.appspot.com/?file_id=1BDawGTK-riXb-PjwFCCqjwZ74yhdzFapw9kT2yJnp88#0',
                ),
              ),
          onPrivacyPolicyTap:
              () => launchUrl(
                Uri.parse(
                  // TODO(nikunj-p-7span): Change your Privacy policy link here
                  'https://codelabs-preview.appspot.com/?file_id=1BDawGTK-riXb-PjwFCCqjwZ74yhdzFapw9kT2yJnp88#0',
                ),
              ),
          messageBeforeLinks: context.t.by_proceeding_accept,
          termsText: context.t.terms_and_condition,
          andText: context.t.and,
          privacyText: context.t.privacy_policy,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return AppButton(
          isLoading: state.status.isInProgress,
          text: context.t.sign_in,
          onPressed: () {
            TextInput.finishAutofillContext();
            if (!state.isUserConsent) {
              showAppSnackbar(context, context.t.please_accept_terms, type: SnackbarType.failed);
            } else {
              context.read<SignInBloc>().add(const SignInSubmitted());
            }
          },
          isExpanded: true,
        );
      },
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton();

  @override
  Widget build(BuildContext context) {
    return AppButton(
      buttonType: ButtonType.outlined,
      textColor: context.colorScheme.primary500,
      backgroundColor: context.colorScheme.white,
      text: context.t.sign_up,
      onPressed: () async {
        await context.pushRoute(const SignUpRoute());
      },
      isExpanded: true,
    );
  }
}

class _ContinueWithGoogleButton extends StatelessWidget {
  const _ContinueWithGoogleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return AppButton(
          buttonType: ButtonType.outlined,
          textColor: context.colorScheme.primary900,
          backgroundColor: Colors.transparent,
          text: context.t.continue_with_google,
          icon: Assets.icons.icGmail.svg(),
          isLoading: state.status.isInProgress,
          onPressed: () => _loginWithGoogle(context),
          isExpanded: true,
        );
      },
    );
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    await GoogleAuthHelper.signIn(
      context,
      onSuccess: () {
        if (context.mounted) {
          showAppSnackbar(context, context.t.sign_in_successful);
        }
      },
      onError: (error) {
        if (context.mounted) {
          showAppSnackbar(context, error.toString(), type: SnackbarType.failed);
        }
      },
    ).then((userCredential) {
      if (userCredential != null && context.mounted) {
        final user = userCredential.user;
        if (user != null) {
          final requestModel = AuthRequestModel(
            name: user.displayName,
            email: user.email,
            provider: 'google',
            providerId: user.uid,
            providerToken: user.uid,
            oneSignalPlayerId: 'playerId if onesignal is integrated',
          );

          context.read<SignInBloc>().add(SignInWithGoogleTaped(requestModel: requestModel));
        }
      }
    });
  }
}

class _ContinueWithAppleButton extends StatelessWidget {
  const _ContinueWithAppleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return AppButton(
          buttonType: ButtonType.outlined,
          textColor: context.colorScheme.primary900,
          backgroundColor: Colors.transparent,
          text: context.t.continue_with_apple,
          icon: Icon(Icons.apple, color: context.colorScheme.black),
          onPressed: () => _loginWithApple(context),
          isLoading: state.status == FormzSubmissionStatus.success,
          isExpanded: true,
        );
      },
    );
  }

  void _loginWithApple(BuildContext context) {
    unawaited(
      AppleAuthHelper.signIn(
        context,
        onSuccess: () {
          if (context.mounted) {
            showAppSnackbar(context, context.t.sign_in_successful);
          }
        },
        onError: (error) {
          if (context.mounted) {
            if (error.code == AuthorizationErrorCode.canceled) {
              showAppSnackbar(context, context.t.operation_cancelled, type: SnackbarType.failed);
            } else {
              showAppSnackbar(context, error.message, type: SnackbarType.failed);
            }
          }
        },
      ).then((requestModel) {
        if (requestModel != null && context.mounted) {
          context.read<SignInBloc>().add(SignInWithGoogleTaped(requestModel: requestModel));
        }
      }),
    );
  }
}
