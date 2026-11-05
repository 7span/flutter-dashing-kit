---
trigger: always_on
description: "Flutter Auto Route Implementation Rule"
---

## Overview
This rule ensures consistent implementation of Auto Route navigation in Flutter applications with proper annotations, route configurations, and BLoC integration.

## Rule Application

### 1. Screen Widget Annotation
- **ALWAYS** annotate screen widgets with `@RoutePage()` decorator
- Place the annotation directly above the class declaration
- No additional parameters needed for basic routes

### 2. For simple screens without state management:
```dart
@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return // Your widget implementation
  }
}
```

### 3. For screens requiring state management with BLoC/Cubit:
```dart
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
            create: (context) => HomeBloc(
              repository: context.read<HomeRepository>()
            )..safeAdd(const FetchPostsEvent()),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              context.read<AuthRepository>(),
              context.read<ProfileRepository>(),
            )..fetchProfileDetail(),
          ),
        ],
        child: this,
      ),
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

### 4. Route Configuration in app_router.dart
```dart
@AutoRouterConfig(replaceInRouteName: 'Page|Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      page: SplashRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(page: HomeRoute.page),
    // Add new routes here
  ];
}
```

### 5. Code Generation Command
After adding new routes, **ALWAYS** run:
```bash
melos run build-runner
```

### 6. Use BackButtonListener instead of PopScope while project contains AutoRoute to avoid conflicts because of auto_route.
For this you can wrap the AppScafflold with BackButtonListener like this,
```dart
@override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: (){},
      child: AppScafflold(),
    );
  }
```

## Implementation Checklist

### For New Screens:
- [ ] Add `@RoutePage()` annotation above class declaration
- [ ] Choose appropriate pattern (StatelessWidget vs StatefulWidget with AutoRouteWrapper)
- [ ] If using BLoC, implement `AutoRouteWrapper` interface
- [ ] Add route configuration in `app_router.dart`
- [ ] Run build runner command
- [ ] Verify route generation in generated files

### For BLoC Integration:
- [ ] Implement `AutoRouteWrapper` interface
- [ ] Use `MultiRepositoryProvider` for dependency injection
- [ ] Use `MultiBlocProvider` for state management
- [ ] Initialize BLoCs with required repositories
- [ ] Return `this` as child in wrapper

### Route Configuration:
- [ ] Add route to `routes` list in `AppRouter`
- [ ] Use `RouteNameHere.page` format
- [ ] Add guards if authentication required
- [ ] Set `initial: true` for entry point routes

## Common Patterns

### Basic Navigation Route
```dart
AutoRoute(page: ScreenNameRoute.page)
```

### Protected Route with Guard
```dart
AutoRoute(
  page: ScreenNameRoute.page,
  guards: [AuthGuard()],
)
```

### Initial/Entry Route
```dart
AutoRoute(
  initial: true,
  page: SplashRoute.page,
  guards: [AuthGuard()],
)
```

## Notes
- Route names are automatically generated based on screen class names
- The `replaceInRouteName` parameter converts 'Page' or 'Screen' suffixes to 'Route'
- Always run code generation after route changes
- Use lazy loading for BLoCs when appropriate (set `lazy: false` for immediate initialization)