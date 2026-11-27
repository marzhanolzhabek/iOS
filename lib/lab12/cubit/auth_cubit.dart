
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    if (isClosed) return;

    if (email.trim().toLowerCase() == 'student@narxoz.kz' &&
        password == '123456') {
      emit(const AuthSuccess(
        username: 'LUNA Member',
        email: 'student@narxoz.kz',
      ));
    } else {
      emit(const AuthError(
        'Incorrect email or password. Please try again.',
      ));
    }
  }

  void reset() {
    emit(const AuthInitial());
  }
}
