---
name: unit-test
description: Write and maintain unit tests for Flutter BLoCs, Cubits, TaskEither Repositories, and Models using bloc_test and mocktail. Trigger when asked to test, add unit tests, or verify logic in this monorepo.
---

# Unit Test Skill

Guide for authoring unit tests in this Flutter Monorepo across BLoCs, Cubits, Repositories (`TaskEither`), and Models.

---

## 1. Test File Placement & Naming

Mirror the source directory structure inside the `test/` folder of the owning package/app:

```
apps/app_core/test/modules/[feature]/
├── bloc/
│   └── [feature]_bloc_test.dart
├── repository/
│   └── [feature]_repository_test.dart
└── model/
    └── [feature]_model_test.dart
```

---

## 2. BLoC & Cubit Unit Tests (`bloc_test`)

Always use `package:bloc_test` and `package:mocktail`.

### Pattern:
```dart
import 'package:app_core/modules/[feature]/bloc/[feature]_bloc.dart';
import 'package:app_core/modules/[feature]/model/[feature]_model.dart';
import 'package:app_core/modules/[feature]/repository/[feature]_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class Mock[Feature]Repository extends Mock implements I[Feature]Repository {}

void main() {
  late Mock[Feature]Repository mockRepository;
  late [Feature]Bloc bloc;

  setUp(() {
    mockRepository = Mock[Feature]Repository();
    bloc = [Feature]Bloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('[Feature]Bloc', () {
    test('initial state is correct', () {
      expect(bloc.state, equals(const [Feature]State()));
    });

    blocTest<[Feature]Bloc, [Feature]State>(
      'emits [loading, loaded] when [Feature]FetchDataEvent succeeds',
      setUp: () {
        when(() => mockRepository.fetchData()).thenReturn(
          TaskEither.right(const [/* mock model data */]),
        );
      },
      build: () => [Feature]Bloc(repository: mockRepository),
      act: (bloc) => bloc.add(const [Feature]FetchDataEvent()),
      expect: () => [
        const [Feature]State(status: ApiStatus.loading),
        isA<[Feature]State>()
            .having((s) => s.status, 'status', ApiStatus.loaded)
            .having((s) => s.data, 'data', isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchData()).called(1);
      },
    );

    blocTest<[Feature]Bloc, [Feature]State>(
      'emits [loading, error] when [Feature]FetchDataEvent fails',
      setUp: () {
        when(() => mockRepository.fetchData()).thenReturn(
          TaskEither.left(APIFailure(error: 'Network error')),
        );
      },
      build: () => [Feature]Bloc(repository: mockRepository),
      act: (bloc) => bloc.add(const [Feature]FetchDataEvent()),
      expect: () => [
        const [Feature]State(status: ApiStatus.loading),
        isA<[Feature]State>()
            .having((s) => s.status, 'status', ApiStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
      ],
    );
  });
}
```

---

## 3. Repository Tests with `TaskEither`

Repositories in this monorepo return `TaskEither<Failure, T>`. Test both Left and Right branches using `.run()`:

```dart
void main() {
  group('[Feature]Repository', () {
    test('returns Right(data) on 200 HTTP response', () async {
      final resultEither = await repository.fetchData().run();

      expect(resultEither.isRight(), isTrue);
      resultEither.fold(
        (failure) => fail('Expected Right, got Left: $failure'),
        (data) => expect(data, isNotEmpty),
      );
    });

    test('returns Left(APIFailure) on error response', () async {
      final resultEither = await repository.fetchData().run();

      expect(resultEither.isLeft(), isTrue);
      resultEither.fold(
        (failure) => expect(failure, isA<APIFailure>()),
        (data) => fail('Expected Left, got Right: $data'),
      );
    });
  });
}
```

---

## 4. Model Tests (`fromJson` & `toJson`)

Ensure models serialize and deserialize without loss:

```dart
void main() {
  group('[Feature]Model', () {
    const jsonMap = {
      'id': 1,
      'title': 'Test title',
    };

    test('fromJson constructs valid model instance', () {
      final model = [Feature]Model.fromJson(jsonMap);
      expect(model.id, equals(1));
      expect(model.title, equals('Test title'));
    });

    test('toJson returns matching map', () {
      final model = [Feature]Model.fromJson(jsonMap);
      expect(model.toJson(), equals(jsonMap));
    });
  });
}
```

---

## 5. Verification Protocol

Run targeted test commands:
```bash
flutter test apps/app_core/test/modules/[feature]/bloc/[feature]_bloc_test.dart
flutter analyze
```
All tests must pass with zero analyzer warnings.

