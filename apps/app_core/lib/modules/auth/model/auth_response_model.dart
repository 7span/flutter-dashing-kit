class AuthResponseModel {
  AuthResponseModel({
    required this.email,
    required this.id,
    this.name,
    this.avatar,
  });

  factory AuthResponseModel.fromMap(Map<String, dynamic> map, {String? defaultEmail}) {
    return AuthResponseModel(
      id: map['id']?.toString() ?? '1',
      email: map['email']?.toString() ?? defaultEmail ?? '',
      name: map['name'] as String?,
      avatar: map['avatar'] as String?,
    );
  }

  String? name;
  String id;
  String email;
  String? avatar;
}
