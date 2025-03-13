import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';

import '../../../data/models/user_model.dart';
import '../../../data/response/login_response.dart';
import '../../../services/reporitories/auth_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo _loginRepo = LoginRepo();
  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      if (event is Login) {
        emit(LoginLoading());

        try {
          LoginResponse response = await _loginRepo.login(
              username: event.user, password: event.password);

          if (response.userInfo != null) {
            Box<UserModel> _user = await Hive.openBox<UserModel>('userModel');

            await _user.clear();
            await _user.add(UserModel(
              username: response.userInfo!.username!,
              name: response.userInfo!.name!,        
              userId: response.userInfo!.id ?? 1,
              isSuperuser: response.userInfo!.isSuperuser!,
              email: response.userInfo!.email!,
              accessToken: response.token!
            ));
          }
          emit(LoginSuccess(accessToken: response.token!));
        } catch (e) {
          print(e);
          emit(LoginError(error: e.toString()));
        }
      }
      if (event is Logout) {
        emit(LogoutLoading());
        try {
          print("load event logout");
          Box<UserModel> _userModel =
              await Hive.openBox<UserModel>('userModel');
          await _userModel.clear();
          emit(LogoutSuccess());
        } catch (e) {
          print(e);
          emit(LogoutFailure(message: e.toString()));
        }
      }
    });
  }
}