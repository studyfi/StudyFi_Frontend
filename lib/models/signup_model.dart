class SignupModel {
  final String name;
  final String email;
  final String password;
  final String phoneContact;
  final String birthDate;
  final String country;
  final String aboutMe;
  final String currentAddress;
  // final String profileFile; // Add profile file path
  // final String coverFile; // Add cover file path

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneContact,
    required this.birthDate,
    required this.country,
    required this.aboutMe,
    required this.currentAddress,
    // required this.profileFile, // Add profile file path
    // required this.coverFile, // Add cover file path
  });

  // Optional: Add a method to convert to JSON if needed.
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phoneContact': phoneContact,
        'birthDate': birthDate,
        'country': country,
        'aboutMe': aboutMe,
        'currentAddress': currentAddress,
        // 'profileFile': profileFile,
        // 'coverFile': coverFile,
      };
}
