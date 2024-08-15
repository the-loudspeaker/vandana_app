class UserEntity {
  final String email;
  final String name;
  final bool admin;

  UserEntity({required this.email, required this.name, required this.admin});

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
        email: map['email'], name: map['name'], admin: map['admin']);
  }
  static List<UserEntity> fromList(List<Map<String, dynamic>> list) {
    return list.map((e) => UserEntity.fromMap(e)).toList();
  }
}
