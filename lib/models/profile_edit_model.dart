class ProfileEditModel {
  final String name;
  final String email;
  final String password;
  final String phoneContact;
  final String birthDate;
  final String country;
  final String aboutMe;
  final String currentAddress;
  final String? profileFile; // path to file, nullable
  final String? coverFile; // path to file, nullable

  ProfileEditModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneContact,
    required this.birthDate,
    required this.country,
    required this.aboutMe,
    required this.currentAddress,
    this.profileFile,
    this.coverFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phoneContact': phoneContact,
      'birthDate': birthDate,
      'country': country,
      'aboutMe': aboutMe,
      'currentAddress': currentAddress,
      'profileFile': profileFile,
      'coverFile': coverFile,
    };
  }
}
