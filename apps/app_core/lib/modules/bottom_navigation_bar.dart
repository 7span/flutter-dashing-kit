import 'dart:async';

import 'package:app_core/app/routes/app_router.dart';
import 'package:app_core/core/domain/bloc/notification_cubit/notification_cubit.dart';
import 'package:app_core/modules/home/repository/home_repository.dart';
import 'package:app_notification_service/notification_service.dart';
import 'package:app_translations/app_translations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class BottomNavigationBarScreen extends StatefulWidget
    implements AutoRouteWrapper {
  const BottomNavigationBarScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return RepositoryProvider<HomeRepository>(
      create: (context) => HomeRepository(),
      child: BlocProvider(
        create: (context) {
          final cubit = NotificationCubit(context.read<HomeRepository>());
          unawaited(cubit.checkNotificationPermissionStatus());
          return cubit;
        },
        child: this,
      ),
    );
  }

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState
    extends State<BottomNavigationBarScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_checkNotificationPermissionStatus());
  }

  Future<void> _checkNotificationPermissionStatus() async {
    await context
        .read<NotificationCubit>()
        .checkNotificationPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listener: (context, state) async {
        if (state.notificationPermissionStatus ==
            PermissionStatus.denied ||
            state.notificationPermissionStatus ==
                PermissionStatus.permanentlyDenied) {
          await OneSignalService().requestNotificationPermission();
          if (!context.mounted) return;
          await context
              .read<NotificationCubit>()
              .checkNotificationPermissionStatus();
        } else if (state.notificationPermissionStatus ==
            PermissionStatus.granted) {
          await context
              .read<NotificationCubit>()
              .checkAndSavePlayerID();
        }
      },
      builder: (context, state) {
        return AutoTabsRouter(
          /// list of your tab routes
          /// routes used here must be declared as children
          /// routes of /dashboard
          routes: const [HomeRoute(), ProfileRoute()],
          transitionBuilder:
              (context, child, animation) =>
              FadeTransition(
                opacity: animation,

                /// the passed child is technically our animated selected-tab page
                child: child,
              ),
          builder: (context, child) {
            /// obtain the scoped TabsRouter controller using context
            final tabsRouter = AutoTabsRouter.of(context);

            /// Here we're building our Scaffold inside of AutoTabsRouter
            /// to access the tabsRouter controller provided in this context
            return AppScaffold(
              body: child,
              bottomNavigationBar:
              context.topRouteMatch.meta['hideNavBar'] == true
                  ? null
                  : BottomNavigationBar(
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.list),
                    label: context.t.users,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: context.t.profile,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
