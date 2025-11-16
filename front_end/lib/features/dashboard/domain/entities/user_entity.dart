// features/user/domain/entities/user_entity.dart
class UserEntity {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
    required this.createdAt,
  });
}