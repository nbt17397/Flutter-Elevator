part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class FetchRegisterEvent extends RegisterEvent {
  final int boardId;
  FetchRegisterEvent(this.boardId);
}