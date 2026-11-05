import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:app_core/app/helpers/extensions/extensions.dart';
import 'package:app_core/app/helpers/mixins/pagination_mixin.dart';
import 'package:app_core/app/routes/app_router.dart';
import 'package:app_core/modules/auth/repository/auth_repository.dart';
import 'package:app_core/modules/home/bloc/home_bloc.dart';
import 'package:app_core/modules/home/model/post_response_model.dart';
import 'package:app_core/modules/home/repository/home_repository.dart';
import 'package:app_core/modules/profile/bloc/profile_cubit.dart';
import 'package:app_core/modules/profile/repository/profile_repository.dart';
import 'package:app_translations/app_translations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomeScreen extends StatefulWidget implements AutoRouteWrapper {
  const HomeScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => HomeRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
        RepositoryProvider(create: (context) => const AuthRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create:
                (context) =>
                    HomeBloc(repository: context.read<HomeRepository>())
                      ..safeAdd(const FetchPostsEvent()),
          ),
          BlocProvider(
            create: (context) {
              final cubit = ProfileCubit(
                context.read<AuthRepository>(),
                context.read<ProfileRepository>(),
              );
              unawaited(cubit.fetchProfileDetail());
              return cubit;
            },
          ),
        ],

        child: this,
      ),
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with PaginationService {
  late final ScrollController pageScrollController;

  @override
  void initState() {
    super.initState();
    pageScrollController = scrollController;
  }

  @override
  void dispose() {
    pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: CustomAppBar(title: context.t.homepage_title, actions: const [ProfileImage()]),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              buildWhen:
                  (previous, current) =>
                      previous.apiStatus != current.apiStatus ||
                      previous.postList.length != current.postList.length,
              builder: (context, state) {
                switch (state.apiStatus) {
                  case ApiStatus.initial:
                  case ApiStatus.loading:
                    return const Center(child: AppCircularProgressIndicator());
                  case ApiStatus.loaded:
                    return _ListWidget(hasReachedMax: state.hasReachedMax, post: state.postList);
                  case ApiStatus.error:
                    return AppText.L(text: context.t.post_error);
                  case ApiStatus.empty:
                    return Center(child: Text(context.t.empty_msg));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onEndScroll() {
    context.read<HomeBloc>().safeAdd(const LoadMorePostsEvent());
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return AppProfileImage(
          imageUrl: state.userModel?.profilePicUrl,
          onTap: () async {
            await context.router.push(const EditProfileRoute());
          },
        );
      },
    );
  }
}

class _ListWidget extends StatefulWidget {
  const _ListWidget({required this.hasReachedMax, required this.post});

  final bool hasReachedMax;
  final List<PostResponseModel> post;

  @override
  State<_ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<_ListWidget> with PaginationService {
  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: () async => context.read<HomeBloc>().add(const FetchPostsEvent()),
      child: ListView.builder(
        controller: scrollController,
        itemCount: widget.post.length + (widget.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= widget.post.length) {
            return const Center(child: AppCircularProgressIndicator());
          }
          return Container(
            padding: const EdgeInsets.symmetric(vertical: Insets.xxxxlarge80),
            child: Text("${widget.post[index].title ?? ''} ${widget.post[index].body ?? ''}"),
          );
        },
      ),
    );
  }

  @override
  void onEndScroll() {
    context.read<HomeBloc>().add(const LoadMorePostsEvent());
  }
}
