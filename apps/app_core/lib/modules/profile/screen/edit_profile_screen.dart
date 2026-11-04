
import 'dart:async';

import 'package:api_client/api_client.dart';
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
class EditProfileScreen extends StatelessWidget implements AutoRouteWrapper {
  const EditProfileScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (context) => const AuthRepository()),
        RepositoryProvider<ProfileRepository>(create: (context) => ProfileRepository()),
      ],
      child: BlocProvider(
        create: (context) {
          final cubit = ProfileCubit(
            RepositoryProvider.of<AuthRepository>(context),
            RepositoryProvider.of<ProfileRepository>(context),
          );
          unawaited(cubit.fetchProfileDetail());
          return cubit;
        },
        child: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.error) {
          showAppSnackbar(context, state.errorMessage, type: SnackbarType.failed);
        } else if (state.profileActionStatus == ProfileActionStatus.profileEdited) {
          showAppSnackbar(context, context.t.profile_edit_success);
        } else if (state.isPermissionDenied ?? false) {
          showAppSnackbar(
            context,
            context.t.please_unable_media_permission,
            type: SnackbarType.failed,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: context.t.edit_profile),
          body:
              state.apiStatus == ApiStatus.loading
                  ? const Center(child: AppLoadingIndicator())
                  : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.medium16),
                    child: Column(
                      spacing: Insets.medium16,
                      children: [_ProfileImage(), _NameTextFiled(), _EditButton()],
                    ),
                  ),
        );
      },
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.imageFile != current.imageFile,
      builder: (context, state) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium16),
              child:
                  state.imageFile != null
                      ? AppNetworkImage(
                        imageSource: AppImageSource.memory,
                        imageFile: state.imageFile,
                        imageHeight: 120,
                        imageWidth: 120,
                      )
                      : AppNetworkImage(
                        imageUrl: state.userModel?.profilePicUrl,
                        imageHeight: 120,
                        imageWidth: 120,
                      ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await context.read<ProfileCubit>().onAddImageTap();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NameTextFiled extends StatelessWidget {
  const _NameTextFiled();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return AppTextField(
          label: context.t.name,
          initialValue: state.userModel?.name,
          backgroundColor: context.colorScheme.primary100,
          onChanged: (value) {
            context.read<ProfileCubit>().onNameChange(value);
          },
        );
      },
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return AppButton(
          isLoading: state.apiStatus == ApiStatus.loading,
          onPressed: () async {
            await context.read<ProfileCubit>().onEditTap();
          },
          isExpanded: true,
          text: context.t.edit_profile,
        );
      },
    );
  }
}
