import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:cleanconnect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/features/auth/domain/usecases/login_usecase.dart';
import 'package:cleanconnect/features/auth/domain/usecases/register_usecase.dart';
import 'package:cleanconnect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:cleanconnect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cleanconnect/features/auth/presentation/state/auth_state.dart';


class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock
    implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      LoginUsecaseParams(
        email: '',
        password: '',
      ),
    );

    registerFallbackValue(
      RegisterUsecaseParams(
        fullName: '',
        email: '',
        password: '',
        address: '',
        profilePicture: '',
        phoneNumber: '',
        confirmPassword: '',
      ),
    );
  });

  late ProviderContainer container;

  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider
            .overrideWithValue(mockGetCurrentUserUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test("Initial state should be AuthStatus.initial", () {
    final state = container.read(authViewModelProvider);

    expect(state.status, AuthStatus.initial);
    expect(state.user, null);
    expect(state.errorMessage, null);
  });

  group("Login Tests", () {
    test("Login Success → Authenticated", () async {
      final fakeUser = AuthEntity(
        authId: '1',
        fullName: 'Test User',
        email: 'test@gmail.com',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
      );

      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => Right(fakeUser));

      await container.read(authViewModelProvider.notifier).login(
            email: 'test@gmail.com',
            password: 'password',
          );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.authenticated);
      expect(state.user, fakeUser);
      expect(state.errorMessage, null);
    });

    test("Login Failure → Error", () async {
      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) async => const Left(
          ApiFailure(message: 'Invalid Credentials'),
        ),
      );

      await container.read(authViewModelProvider.notifier).login(
            email: 'wrong@gmail.com',
            password: 'wrong',
          );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.error);
      expect(state.user, null);
      expect(state.errorMessage, 'Invalid Credentials');
    });
  });

  group("Register Tests", () {
    test("Register Success → Registered", () async {
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      await container.read(authViewModelProvider.notifier).register(
            fullName: 'New User',
            email: 'new@gmail.com',
            password: 'password',
            address: 'Kathmandu',
            profilePicture: 'profile.png',
            phoneNumber: '9800000000',
          );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.registered);
      expect(state.errorMessage, null);
    });

    test("Register Failure → Error", () async {
      when(() => mockRegisterUsecase(any())).thenAnswer(
        (_) async => const Left(
          ApiFailure(message: 'Email Already Exists'),
        ),
      );

      await container.read(authViewModelProvider.notifier).register(
            fullName: 'User',
            email: 'duplicate@gmail.com',
            password: 'password',
            address: 'Kathmandu',
            profilePicture: 'profile.png',
            phoneNumber: '9800000000',
          );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email Already Exists');
    });
  });

  group("GetCurrentUser Tests", () {
    test("Success → Authenticated", () async {
      final fakeUser = AuthEntity(
        authId: '99',
        fullName: 'Current User',
        email: 'current@gmail.com',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
      );

      when(() => mockGetCurrentUserUsecase())
          .thenAnswer((_) async => Right(fakeUser));

      await container
          .read(authViewModelProvider.notifier)
          .getCurrentUser();

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.authenticated);
      expect(state.user, fakeUser);
    });

    test("Failure → Unauthenticated", () async {
      when(() => mockGetCurrentUserUsecase()).thenAnswer(
        (_) async => const Left(
          LocalDataBaseFailure(message: 'No User Found'),
        ),
      );

      await container
          .read(authViewModelProvider.notifier)
          .getCurrentUser();

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
      expect(state.errorMessage, 'No User Found');
    });
  });

  group("Logout Tests", () {
    test("Logout Success → Unauthenticated", () async {
      when(() => mockLogoutUsecase())
          .thenAnswer((_) async => const Right(true));

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
    });

    test("Logout Failure → Error", () async {
      when(() => mockLogoutUsecase()).thenAnswer(
        (_) async => const Left(
          ApiFailure(message: 'Logout Failed'),
        ),
      );

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Logout Failed');
    });
  });
}