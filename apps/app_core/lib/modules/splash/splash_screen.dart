import 'dart:async';

import 'package:app_core/app/helpers/logger_helper.dart';
import 'package:app_core/app/routes/app_router.dart';
import 'package:app_subscription/app_subscription_api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final CustomInAppPurchase customInAppPurchase;

  @override
  void initState() {
    unawaited(handleSubscription());
    super.initState();
  }

  Future<void> handleSubscription() async {
    customInAppPurchase = CustomInAppPurchase();
    customInAppPurchase.init();
    await customInAppPurchase.completePendingPurchases();
    await navigate();
  }

  Future<void> navigate() async {
    await Future<void>.delayed(2.seconds);
    if (!mounted) return;
    await context.replaceRoute(const BottomNavigationBarRoute());
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(body: Center(child: FlutterLogo(size: 40)));
  }

  Future<void> disposeSubscription() async {
    await customInAppPurchase.dispose();
  }

  @override
  void dispose() {
    flog('dispose of splash');
    unawaited(disposeSubscription());
    super.dispose();
  }
}
