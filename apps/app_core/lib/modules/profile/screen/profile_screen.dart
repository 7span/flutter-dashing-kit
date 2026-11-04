import 'package:api_client/api_client.dart';
import 'package:app_core/app/routes/app_router.dart';
import 'package:app_core/core/presentation/widgets/app_snackbar.dart';
import 'package:app_core/modules/auth/repository/auth_repository.dart';
import 'package:app_core/modules/profile/bloc/profile_cubit.dart';
import 'package:app_core/modules/profile/repository/profile_repository.dart';
import 'package:app_translations/app_translations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget implements AutoRouteWrapper {
  const ProfileScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => const AuthRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(),
        ),
      ],
      child: BlocProvider(
        create:
            (context) => ProfileCubit(
              RepositoryProvider.of<AuthRepository>(context),
              RepositoryProvider.of<ProfileRepository>(context),
            )..fetchProfileDetailsFromHive(),
        child: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state.apiStatus == ApiStatus.error) {
          showAppSnackbar(
            context,
            state.errorMessage,
            type: SnackbarType.failed,
          );
        } else if (state.profileActionStatus ==
                ProfileActionStatus.logoutDone ||
            state.profileActionStatus == ProfileActionStatus.accountDeleted) {
          await context.router.replaceAll(const [SignInRoute()]);
        }
      },
      builder: (context, state) {
        return AppScaffold(
          appBar: CustomAppBar(title: context.t.my_profile),
          body: Padding(
            padding: const EdgeInsets.all(Insets.medium16),
            child: Column(
              spacing: Insets.medium16,
              children: [
                ProfileListTile(
                  onTap: () async {
                    await context.pushRoute(const EditProfileRoute());
                  },
                  title: context.t.my_profile,
                ),
                ProfileListTile(
                  title: context.t.logout,
                  onTap: () async {
                    await showDialog<void>(
                      context: context,
                      useRootNavigator: false,
                      builder:
                          (_) => AppAlertDialog(
                            rightText: context.t.yes,
                            leftText: context.t.no,
                            title: context.t.logout,
                            content: context.t.logout_description,
                            onRightOptionTap: () async {
                              await context.read<ProfileCubit>().logout();
                            },
                            onLeftOptionTap: () async {
                              if (context.mounted) {
                                await context.maybePop();
                              }
                            },
                          ),
                    );
                  },
                ),
                ProfileListTile(
                  title: context.t.delete_account,
                  onTap: () async {
                    await showDialog<void>(
                      context: context,
                      useRootNavigator: false,
                      builder:
                          (_) => AppAlertDialog(
                            rightText: context.t.yes,
                            leftText: context.t.no,
                            title: context.t.delete_my_account,
                            content: context.t.delete_account_description,
                            onRightOptionTap: () async {
                              await context
                                  .read<ProfileCubit>()
                                  .deleteUserAccount();
                            },
                            onLeftOptionTap: () async {
                              if (context.mounted) {
                                await context.maybePop();
                              }
                            },
                          ),
                    );
                  },
                ),
                ProfileListTile(
                  title: context.t.change_password,
                  onTap: () async {
                    await context.pushRoute(const ChangePasswordRoute());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({required this.title, required this.onTap, super.key});

  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: AppText.L(text: title),
      trailing: const Icon(Icons.arrow_right_alt_outlined),
    );
  }
}
