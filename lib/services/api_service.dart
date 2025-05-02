import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/models/group_data_model.dart';
import 'package:studyfi/models/not_joined_group_model.dart';
import 'package:studyfi/models/profile_edit_model.dart';
import 'package:studyfi/models/signup_model.dart';
import 'package:studyfi/models/profile_model.dart';
import 'dart:io';

class ApiService {
  String baseUrl = "http://192.168.1.100:8080/api/v1";

  Future<bool> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Login successful: $responseData');
        int userId = responseData['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        await prefs.setString(
            'profileImageUrl', responseData['profileImageUrl'] ?? '');
        return true;
      } else {
        print('Login failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<bool> signup(SignupModel signupData, BuildContext context) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/register'),
      );

      request.fields['name'] = signupData.name;
      request.fields['email'] = signupData.email;
      request.fields['password'] = signupData.password;
      request.fields['phoneContact'] = signupData.phoneContact;
      request.fields['birthDate'] = signupData.birthDate;
      request.fields['country'] = signupData.country;
      request.fields['aboutMe'] = signupData.aboutMe;
      request.fields['currentAddress'] = signupData.currentAddress;

      if (signupData.profileFile != null) {
        final profileFile = File(signupData.profileFile!);
        if (await profileFile.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'profileFile',
            signupData.profileFile!,
          ));
        } else {
          print('Profile file does not exist: ${signupData.profileFile}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image file is invalid.')),
          );
          return false;
        }
      }

      if (signupData.coverFile != null) {
        final coverFile = File(signupData.coverFile!);
        if (await coverFile.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'coverFile',
            signupData.coverFile!,
          ));
        } else {
          print('Cover file does not exist: ${signupData.coverFile}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover image file is invalid.')),
          );
          return false;
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        print('Signup successful: $responseData');
        int userId = responseData['id'] ?? -1;
        if (userId != -1) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
        }
        return true;
      } else {
        final responseData = json.decode(responseBody);
        print('Signup failed: ${response.statusCode}');
        print('Response body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Signup failed: ${responseData['message'] ?? 'Invalid data'}')),
        );
        return false;
      }
    } catch (e) {
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during signup.')),
      );
      return false;
    }
  }

  Future<UserData> fetchUserData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserData.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<bool> updateProfile(
      int userId, ProfileEditModel profileData, BuildContext context) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/users/profile/$userId'),
      );

      // Add form fields
      request.fields['name'] = profileData.name;
      request.fields['email'] = profileData.email;
      // Only include password if non-empty
      if (profileData.password.isNotEmpty) {
        request.fields['password'] = profileData.password;
      }
      request.fields['phoneContact'] = profileData.phoneContact;
      request.fields['birthDate'] = profileData.birthDate;
      request.fields['country'] = profileData.country;
      request.fields['aboutMe'] = profileData.aboutMe;
      request.fields['currentAddress'] = profileData.currentAddress;

      // Add profile file if available
      if (profileData.profileFile != null) {
        final profileFile = File(profileData.profileFile!);
        if (await profileFile.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'profileFile', // Confirm this matches server expectation
            profileData.profileFile!,
          ));
          print('Added profile file: ${profileData.profileFile}');
        } else {
          print('Profile file does not exist: ${profileData.profileFile}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image file is invalid.')),
          );
          return false;
        }
      }

      // Add cover file if available
      if (profileData.coverFile != null) {
        final coverFile = File(profileData.coverFile!);
        if (await coverFile.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'coverFile', // Confirm this matches server expectation
            profileData.coverFile!,
          ));
          print('Added cover file: ${profileData.coverFile}');
        } else {
          print('Cover file does not exist: ${profileData.coverFile}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover image file is invalid.')),
          );
          return false;
        }
      }

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Profile update response status: ${response.statusCode}');
      print('Profile update response body: $responseBody');

      // Check the status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile updated successfully');
        return true;
      } else {
        try {
          final responseData = json.decode(responseBody);
          print('Profile update failed: ${response.statusCode}');
          print('Response body: $responseBody');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile: ${responseData['message'] ?? 'Server error'}',
              ),
            ),
          );
        } catch (e) {
          print('Error parsing response body: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to update profile: Server error')),
          );
        }
        return false;
      }
    } catch (e) {
      print('Error during profile update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred during profile update.')),
      );
      return false;
    }
  }

  Future<GroupData> fetchGroupData(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/groups/user/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GroupData.fromJson(data);
      } else {
        print('Failed to load group. Status code: ${response.statusCode}');
        throw Exception('Failed to load group');
      }
    } catch (e) {
      print('Error fetching group: $e');
      throw Exception('Failed to load group: $e');
    }
  }

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    File? imageFile,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/groups/create');
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['name'] = name;
      request.fields['description'] = description;

      // Add file if exists
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));
      }

      // Send request
      var streamedResponse = await request.send();
      var responseBody = await streamedResponse.stream.bytesToString();

      // Parse and handle response
      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        print(
            'Failed to create group. Status code: ${streamedResponse.statusCode}');
        print('Response body: $responseBody');
        throw Exception('Failed to create group');
      }
    } catch (e) {
      print('Error during group creation: $e');
      throw Exception('Failed to create group: $e');
    }
  }

  Future<bool> addUserToGroup(int userId, int groupId) async {
    final uri = Uri.parse(
      '$baseUrl/users/addToGroup?userId=$userId&groupId=$groupId',
    );

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      print('User added to group successfully');
      return true;
    } else {
      print('Failed to add user to group: ${response.statusCode}');
      print('Response: ${response.body}');
      return false;
    }
  }

  Future<NotJoinedGroupModel> fetchNotJoinedGroupData(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/groups/notjoined/user/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NotJoinedGroupModel.fromJson(data);
      } else {
        print('Failed to load group. Status code: ${response.statusCode}');
        throw Exception('Failed to load group');
      }
    } catch (e) {
      print('Error fetching group: $e');
      throw Exception('Failed to load group: $e');
    }
  }

  Future<List<GroupData>> fetchNotJoinedGroups(int userId) async {
    final url = Uri.parse('$baseUrl/groups/notjoined/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => GroupData.fromJson(item)).toList();
    } else {
      print('Failed to load not-joined groups: ${response.statusCode}');
      throw Exception('Failed to load not-joined groups');
    }
  }
}
