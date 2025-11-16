class UserEntity {

  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
    required this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: json["uid"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      phone: json["phone"],
      address: json["address"],
      avatarUrl: json["avatarUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }

}