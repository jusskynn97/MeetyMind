import 'package:front_end/features/auth/domain/entities/user_entity.dart';

class LoginResponseModel {

  final String token;

  final UserEntity user;

  LoginResponseModel({
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['data']['token'],
      user: UserEntity.fromJson(json['data']['user']),
    );
  }
}