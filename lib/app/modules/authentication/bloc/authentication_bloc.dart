import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';

import '../../../data/models/user_model.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationUninitialized()) {
    on<AuthenticationEvent>((event, emit) async {
      if (event is AppStarted) {
        emit(AuthenticationLoading());

        try {
          // UserModel? _userModel = await HiveService.getUserModel();

          // if (_userModel != null) {
          //   emit(AuthenticationAuthenticated(
          //     accessToken: _userModel.accessToken,
          //   ));
          // } else {
          //   emit(AuthenticationUnauthenticated(type: 0));
          // }
        } catch (e, s) {
          print(e);
          print(s);
          emit(AuthenticationFailure(message: e.toString()));
        }
      }
      if (event is LoggedIn) {
        emit(AuthenticationAuthenticated(accessToken: event.accessToken));
      }

      if (event is ShutDown) {
        Box<UserModel> _userModel = await Hive.openBox<UserModel>('userModel');
        await _userModel.clear();
        emit(AuthenticationUnauthenticated(type: 2));
      }
    });
  }
}