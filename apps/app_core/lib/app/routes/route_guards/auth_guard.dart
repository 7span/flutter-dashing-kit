import 'package:auto_route/auto_route.dart';
import 'package:app_core/app/routes/app_router.dart';
import 'dart:async';

import 'package:app_core/app/helpers/injection.dart';
import 'package:app_core/core/data/services/hive.service.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    /// the navigation is paused until resolver.next() is called with either
    /// true to resume/continue navigation or false to abort navigation
    final userdata = getIt<IHiveService>().getUserData();

    if (userdata.isRight()) {
      /// if user is authenticated we continue
      resolver.next();
    } else {
      /// we redirect the user to our login page
      /// tip: use resolver.redirect to have the redirected route
      /// automatically removed from the stack when the resolver is completed
      unawaited(resolver.redirectUntil(const SignInRoute()));
    }
  }
}
