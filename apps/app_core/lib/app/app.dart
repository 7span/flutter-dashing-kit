
import 'dart:async';

import 'package:app_core/app/config/app_config.dart';
import 'package:app_core/app/helpers/injection.dart';
import 'package:app_core/app/routes/app_router.dart';
import 'package:app_core/core/data/services/connectivity_service.dart';
import 'package:app_core/core/data/services/connectivity_wrapper.dart';
import 'package:app_core/core/data/services/firebase_remote_config_service.dart';
import 'package:app_core/core/data/services/force_update_client.dart';
import 'package:app_core/core/data/services/network_helper.service.dart';
import 'package:app_core/core/domain/bloc/theme_bloc.dart';
import 'package:app_core/core/presentation/screens/error_screen.dart';
import 'package:app_core/core/presentation/widgets/force_update_dialog.dart';
import 'package:app_core/core/presentation/widgets/force_update_widget.dart';
import 'package:app_notification_service/notification_service.dart';
import 'package:app_translations/app_translations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// This class contains the [MaterialApp] widget. In this class, we're
/// doing the following things:
///
/// * Initialization of [AppRouter]
/// * Setup of [Slang](https://pub.dev/packages/slang) for the localization
/// * Setup of [ErrorWidget.builder] in case of any error in debug and release mode
/// * Setting up [Theme] along with [ThemeBloc] so that the user can change
/// the theme from anywhere in the App.
/// * Real-time internet connectivity monitoring with connectivity_plus
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Here we're initializing the theme bloc so that we can change the theme anywhere from the App
  List<BlocProvider<dynamic>> get providers => <BlocProvider<dynamic>>[
    BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
  ];

  final AppRouter _appRouter = AppRouter();

  final _connectivityService = ConnectivityService();
  final FirebaseRemoteConfigService remoteConfig = FirebaseRemoteConfigService();

  @override
  Widget build(BuildContext context) {
    /// Refer this link for the localization package:
    /// https://pub.dev/packages/slang
    return TranslationProvider(
      child: MultiBlocProvider(
        providers: providers,
        child: BlocBuilder<ThemeBloc, AppThemeColorMode>(
          builder: (context, themeMode) {
            return AppResponsiveTheme(
              colorMode: themeMode,
              child: MaterialApp.router(
                routerConfig: _appRouter.config(),
                title: 'Boilerplate App',
                locale: TranslationProvider.of(context).flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                builder: (context, widget) {
                  ErrorWidget.builder = (details) {
                    return ErrorScreen(details: details);
                  };
                  final wrappedWidget = ForceUpdateWidget(
                    navigatorKey: _appRouter.navigatorKey,
                    forceUpdateClient: ForceUpdateClient(
                      iosAppStoreId: AppConfig.iosAppStoreId,
                      remoteConfigService: FirebaseRemoteConfigService(),
                    ),

                    showForceUpdateAlert:
                        (context, {allowCancel = false}) => forceUpdateDialog(
                          context: context,
                          title: context.t.title_app_update,
                          content: context.t.msg_app_update,
                          cancelActionText: allowCancel ? context.t.later : null,
                          defaultActionText: context.t.update,
                        ),
                    showStoreListing: (storeUrl) async {
                      if (await canLaunchUrl(storeUrl)) {
                        await launchUrl(
                          storeUrl,
                          // Open app store app directly (or fallback to browser)
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        debugPrint('Cannot launch URL: $storeUrl');
                      }
                    },
                    onException: (e, st) {
                      debugPrint('Force update error: $e');
                    },
                    child: widget!,
                  );

                  return Overlay(
                    key: _connectivityService.overlayKey,
                    initialEntries: [
                      OverlayEntry(
                        builder:
                            (context) => ConnectivityWrapper(
                              connectivityService: _connectivityService,
                              child: wrappedWidget,
                            ),
                      ),
                    ],
                  );
                },
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(NetWorkInfoService.instance.dispose());
    unawaited(_connectivityService.dispose());
    unawaited(getIt<NotificationServiceInterface>().dispose());
    super.dispose();
  }

}
