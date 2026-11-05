---
trigger: always_on
glob:
description:
---


### Base Module Location
All features must be created within the `lib/modules` directory of the `app_core` package:

```
lib
└── modules 
    └── [feature_name]
```

### Feature Folder Structure
Each feature follows a consistent 4-folder architecture:

```
lib
└── modules
   ├── [feature_name]
   │   ├── bloc/
   │   │   ├── [feature]_event.dart
   │   │   ├── [feature]_state.dart
   │   │   └── [feature]_bloc.dart
   │   ├── model/
   │   │   └── [feature]_model.dart
   │   ├── repository/
   │   │   └── [feature]_repository.dart
   │   └── screen/
   │       └── [feature]_screen.dart
```

## Folder Responsibilities

| Folder | Purpose | Contains |
|--------|---------|----------|
| **bloc** 🧱 | State Management | BLoC, Event, and State classes for the feature |
| **model** 🏪 | Data Models | Dart model classes for JSON serialization/deserialization |
| **repository** 🪣 | API Integration | Functions for API calls and data manipulation |
| **screen** 📲 | User Interface | UI components and screens for the feature |

## Repository Layer Implementation

### Core Pattern: TaskEither Approach
All API integrations use `TaskEither<Failure, T>` pattern from `fp_dart` for functional error handling.

### Abstract Interface Structure
```dart
abstract interface class I[Feature]Repository {
  /// Returns TaskEither where:
  /// - Task: Indicates Future operation
  /// - Either: Success (T) or Failure handling
  TaskEither<Failure, List<[Feature]Model>> fetch[Data]();
}
```

### Implementation Steps

#### 1. HTTP Request Layer 🎁
```dart
class [Feature]Repository implements I[Feature]Repository {
  @override
  TaskEither<Failure, List<[Feature]Model>> fetch[Data]() => 
      mappingRequest('[endpoint]');

  TaskEither<Failure, Response> make[Operation]Request(String url) {
    return ApiClient.request(
      path: url,
      queryParameters: {'_limit': 10},
      requestType: RequestType.get,
    );
  }
}
```

#### 2. Response Validation ✔️
```dart
TaskEither<Failure, List<[Feature]Model>> mappingRequest(String url) =>
    make[Operation]Request(url)
    .chainEither(checkStatusCode);

Either<Failure, Response> checkStatusCode(Response response) => 
    Either<Failure, Response>.fromPredicate(
      response,
      (response) => response.statusCode == 200 || response.statusCode == 304,
      (error) => APIFailure(error: error),
    );
```

#### 3. JSON Decoding 🔁
```dart
TaskEither<Failure, List<[Feature]Model>> mappingRequest(String url) =>
    make[Operation]Request(url)
    .chainEither(checkStatusCode)
    .chainEither(mapToList);

Either<Failure, List<Map<String, dynamic>>> mapToList(Response response) {
  return Either<Failure, List<Map<String, dynamic>>>.safeCast(
    response.data,
    (error) => ModelConversionFailure(error: error),
  );
}
```

#### 4. Model Conversion ✅
```dart
TaskEither<Failure, List<[Feature]Model>> mappingRequest(String url) =>
    make[Operation]Request(url)
    .chainEither(checkStatusCode)
    .chainEither(mapToList)
    .flatMap(mapToModel);

TaskEither<Failure, List<[Feature]Model>> mapToModel(
  List<Map<String, dynamic>> responseList
) => TaskEither<Failure, List<[Feature]Model>>.tryCatch(
  () async => responseList.map([Feature]Model.fromJson).toList(),
  (error, stackTrace) => ModelConversionFailure(
    error: error,
    stackTrace: stackTrace,
  ),
);
```
## Widget Creation Guidelines

❌ Never Use Private Widget Methods

Avoid methods like Widget _buildBottomActions(BuildContext context)
Avoid methods like Widget _buildHeader(BuildContext context)

✅ Always Create StatelessWidget Classes

Create separate StatelessWidget classes for each UI component
Use proper constructor parameters for data passing
Follow clear naming conventions

## Development Guidelines

### Naming Conventions
- **Feature Names**: Use descriptive, lowercase names (auth, home, profile, settings)
- **File Names**: Follow pattern `[feature]_[type].dart`
- **Class Names**: Use PascalCase with feature prefix (`HomeRepository`, `HomeBloc`)
- **Method Names**: Use camelCase with descriptive verbs (`fetchPosts`, `updateProfile`)

### Error Handling Strategy
- **Consistent Failures**: Use standardized `Failure` classes
  - `APIFailure`: For HTTP/network errors
  - `ModelConversionFailure`: For JSON parsing errors
- **Functional Approach**: Chain operations using `TaskEither`
- **No Exceptions**: Handle all errors through `Either` types

### API Integration Patterns
1. **Abstract Interface**: Define contract with abstract interface class
2. **Implementation**: Implement interface in concrete repository class
3. **Function Chaining**: Use `.chainEither()` and `.flatMap()` for sequential operations
4. **Error Propagation**: Let `TaskEither` handle error propagation automatically

### BLoC Integration
- Repository layer feeds directly into BLoC layer
- BLoC handles UI state management
- Repository focuses purely on data operations
- Maintain separation of concerns between layers

## Best Practices

### Code Organization
- Keep abstract interface and implementation in same file for discoverability
- Create separate functions for each operation step
- Use descriptive function names that indicate their purpose
- Maintain consistent error handling patterns across all repositories

### Performance Considerations
- Leverage `TaskEither` for lazy evaluation
- Chain operations efficiently to avoid nested callbacks
- Use appropriate query parameters for data limiting
- Implement proper caching strategies in API client layer

### Testing Strategy
- Mock abstract interfaces for unit testing
- Test each step of the repository chain individually
- Verify error handling for all failure scenarios
- Ensure proper model conversion testing

## Example Feature Names
- `auth` - Authentication and authorization
- `home` - Home screen and dashboard
- `profile` - User profile management
- `settings` - Application settings
- `notifications` - Push notifications
- `search` - Search functionality
- `chat` - Messaging features