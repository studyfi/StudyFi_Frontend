class UserData {
  final int id;
  final String name;
  final String email;
  final String phoneContact;
  final String birthDate;
  final String country;
  final String aboutMe;
  final String currentAddress;
  final String? profileImageUrl;
  final String? coverImageUrl;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneContact,
    required this.birthDate,
    required this.country,
    required this.aboutMe,
    required this.currentAddress,
    this.profileImageUrl,
    this.coverImageUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneContact: json['phoneContact'],
      birthDate: json['birthDate'],
      country: json['country'],
      aboutMe: json['aboutMe'],
      currentAddress: json['currentAddress'],
      profileImageUrl: json['profileImageUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
    );
  }
}
