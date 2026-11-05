---
trigger: always_on
description: "Bloc Rules"
---

## Overview
The BLoC layer serves as the bridge between UI and data layers, managing application state through events and state emissions. This layer follows a strict architectural pattern with three core components.

## BLoC Architecture Components

| Component | Purpose | Description |
|-----------|---------|-------------|
| **State file 💽** | Data Holder | Contains reference to data displayed in UI |
| **Event file ▶️** | UI Triggers | Holds events triggered from the UI layer |
| **BLoC file 🔗** | Logic Controller | Connects State and Event, performs business logic |

## 1. Event File Implementation ⏭️

### Event Class Structure
- **Use sealed classes** instead of abstract classes for events
- **Implement with final classes** for concrete event types
- **Name in past tense** - events represent actions that have already occurred

```dart
part of '[feature]_bloc.dart';

sealed class [Feature]Event extends Equatable {
  const [Feature]Event();

  @override
  List<Object> get props => [];
}

final class [Feature]GetDataEvent extends [Feature]Event {
  const [Feature]GetDataEvent();
}
```

### Event Naming Conventions
- **Base Event Class**: `[BlocSubject]Event`
- **Initial Load Events**: `[BlocSubject]Started`
- **Action Events**: `[BlocSubject][Action]Event`
- **Past Tense**: Events represent completed user actions

### Event Examples
```dart
// Good examples
final class HomeGetPostEvent extends HomeEvent {...}
final class ProfileUpdateEvent extends ProfileEvent {...}
final class AuthLoginEvent extends AuthEvent {...}

// Initial load events
final class HomeStarted extends HomeEvent {...}
final class ProfileStarted extends ProfileEvent {...}
```

## 2. State File Implementation 📌

### State Class Structure
- **Hybrid approach**: Combines Named Constructors and copyWith methods
- **Equatable implementation**: For proper state comparison
- **Private constructor**: Main constructor should be private
- **ApiStatus integration**: Use standardized status enum

```dart
part of '[feature]_bloc.dart';

class [Feature]State extends Equatable {
  final List<[Feature]Model> dataList;
  final bool hasReachedMax;
  final ApiStatus status;
  
  const [Feature]State._({
    this.dataList = const <[Feature]Model>[],
    this.hasReachedMax = false,
    this.status = ApiStatus.initial,
  });

  // Named constructors for common states
  const [Feature]State.initial() : this._(status: ApiStatus.initial);
  const [Feature]State.loading() : this._(status: ApiStatus.loading);
  const [Feature]State.loaded(List<[Feature]Model> dataList, bool hasReachedMax)
      : this._(
          status: ApiStatus.loaded,
          dataList: dataList,
          hasReachedMax: hasReachedMax,
        );
  const [Feature]State.error() : this._(status: ApiStatus.error);

  [Feature]State copyWith({
    ApiStatus? status,
    List<[Feature]Model>? dataList,
    bool? hasReachedMax,
  }) {
    return [Feature]State._(
      status: status ?? this.status,
      dataList: dataList ?? this.dataList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [dataList, hasReachedMax, status];

  @override
  bool get stringify => true;
}
```

### State Design Patterns
- **Private Main Constructor**: Use `._()` pattern
- **Named Constructors**: For common state scenarios
- **CopyWith Method**: For incremental state updates
- **Proper Props**: Include all relevant fields in props list
- **Stringify**: Enable for better debugging

### ApiStatus Enum Usage
```dart
enum ApiStatus {
  initial,    // Before any operation
  loading,    // During API call
  loaded,     // Successful data fetch
  error,      // API call failed
}
```

## 3. BLoC File Implementation 🟦

### BLoC Class Structure
```dart
class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State> {
  [Feature]Bloc({required this.repository}) : super(const [Feature]State.initial()) {
    on<[Feature]GetDataEvent>(_on[Feature]GetDataEvent, transformer: droppable());
  }
  
  final I[Feature]Repository repository;
  int _pageCount = 1;

  FutureOr<void> _on[Feature]GetDataEvent(
    [Feature]GetDataEvent event,
    Emitter<[Feature]State> emit,
  ) async {
    if (state.hasReachedMax) return;

    // Show loader only on initial load
    state.status == ApiStatus.initial
        ? emit(const [Feature]State.loading())
        : emit([Feature]State.loaded(state.dataList, false));

    final dataEither = await repository.fetchData(page: _pageCount).run();
    
    dataEither.fold(
      (error) => emit(const [Feature]State.error()),
      (result) {
        emit([Feature]State.loaded(
          state.dataList.followedBy(result).toList(),
          false,
        ));
        _pageCount++;
      },
    );
  }
}
```

### BLoC Implementation Patterns
- **Repository Injection**: Always inject repository through constructor
- **Event Transformers**: Use appropriate transformers (droppable, concurrent, sequential)
- **State Management**: Check current state before emitting new states
- **Error Handling**: Use TaskEither fold method for error handling
- **Pagination Logic**: Implement proper pagination tracking

### Event Transformers
```dart
// Use droppable for operations that shouldn't be queued
on<Event>(_handler, transformer: droppable());

// Use concurrent for independent operations
on<Event>(_handler, transformer: concurrent());

// Use sequential for ordered operations (default)
on<Event>(_handler, transformer: sequential());
```

## 4. UI Integration with AutoRoute 🎁

### Screen Implementation with Providers
```dart
class [Feature]Screen extends StatefulWidget implements AutoRouteWrapper {
  const [Feature]Screen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return RepositoryProvider<[Feature]Repository>(
      create: (context) => [Feature]Repository(),
      child: BlocProvider(
        lazy: false,
        create: (context) => [Feature]Bloc(
          repository: RepositoryProvider.of<[Feature]Repository>(context),
        )..add(const [Feature]GetDataEvent()),
        child: this,
      ),
    );
  }

  @override
  State<[Feature]Screen> createState() => _[Feature]ScreenState();
}
```

### Provider Pattern Guidelines
- **AutoRouteWrapper**: Implement for scoped provider injection
- **RepositoryProvider**: Provide repository instances
- **BlocProvider**: Provide BLoC instances with repository injection
- **Lazy Loading**: Set `lazy: false` for immediate initialization
- **Initial Events**: Add initial events in BLoC creation

## Development Guidelines

### File Organization
```dart
// Event file structure
part of '[feature]_bloc.dart';
sealed class [Feature]Event extends Equatable {...}

// State file structure  
part of '[feature]_bloc.dart';
class [Feature]State extends Equatable {...}

// BLoC file structure
import 'package:bloc/bloc.dart';
part '[feature]_event.dart';
part '[feature]_state.dart';
```

### Naming Conventions
- **BLoC Class**: `[Feature]Bloc`
- **State Class**: `[Feature]State`  
- **Event Base Class**: `[Feature]Event`
- **Event Handlers**: `_on[Feature][Action]Event`
- **Private Fields**: Use underscore prefix for internal state

### Error Handling Patterns
```dart
// Standard error handling with fold
final resultEither = await repository.operation().run();
resultEither.fold(
  (failure) => emit(const FeatureState.error()),
  (success) => emit(FeatureState.loaded(success)),
);
```

### State Emission Best Practices
- **Check Current State**: Prevent unnecessary emissions
- **Loading States**: Show loader only when appropriate
- **Error Recovery**: Provide ways to retry failed operations
- **Pagination**: Handle has-reached-max scenarios

## Testing Considerations

### BLoC Testing Structure
```dart
group('[Feature]Bloc', () {
  late [Feature]Bloc bloc;
  late Mock[Feature]Repository mockRepository;

  setUp(() {
    mockRepository = Mock[Feature]Repository();
    bloc = [Feature]Bloc(repository: mockRepository);
  });

  blocTest<[Feature]Bloc, [Feature]State>(
    'emits loaded state when event succeeds',
    build: () => bloc,
    act: (bloc) => bloc.add(const [Feature]GetDataEvent()),
    expect: () => [
      const [Feature]State.loading(),
      isA<[Feature]State>().having((s) => s.status, 'status', ApiStatus.loaded),
    ],
  );
});
```

### Build Runner Commands
```bash
# Generate necessary files
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Performance Optimizations

### Memory Management
- **Proper Disposal**: BLoC automatically handles disposal
- **Stream Subscriptions**: Cancel in BLoC close method if manually created
- **Repository Scoping**: Scope repositories to feature level

### Event Handling Efficiency
- **Debouncing**: Use appropriate transformers for user input
- **Caching**: Implement at repository level, not BLoC level
- **Pagination**: Implement proper pagination logic to avoid memory issues