class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phoneContact;
  final String birthDate;
  final String country;
  final String aboutMe;
  final String currentAddress;
  final String? profileImageUrl;
  final String? coverImageUrl;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneContact,
    required this.birthDate,
    required this.country,
    required this.aboutMe,
    required this.currentAddress,
    this.profileImageUrl,
    this.coverImageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'phoneContact': phoneContact,
        'birthDate': birthDate,
        'country': country,
        'aboutMe': aboutMe,
        'currentAddress': currentAddress,
      };
}
