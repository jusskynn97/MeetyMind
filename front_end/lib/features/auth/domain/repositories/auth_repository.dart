import 'package:front_end/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);

  Future<String?> getSavedToken();

  Future<UserEntity> getProfile(String token);
}