import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/models/signup_model.dart';
import 'package:studyfi/models/profile_model.dart';

class ApiService {
  String baseUrl = "http://192.168.1.100:8080/api/v1";

  Future<bool> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'), // Replace with your actual endpoint
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // Or 'multipart/form-data'
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Login successful: $responseData');

        // You can store token or user info here if needed
        // Extract user ID and save it globally using SharedPreferences
        int userId = responseData['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
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
        Uri.parse('$baseUrl/users/register'), // Replace with your API endpoint
      );

      // Add the form fields from the model
      request.fields['name'] = signupData.name;
      request.fields['email'] = signupData.email;
      request.fields['password'] = signupData.password;
      request.fields['phoneContact'] = signupData.phoneContact;
      request.fields['birthDate'] = signupData.birthDate;
      request.fields['country'] = signupData.country;
      request.fields['aboutMe'] = signupData.aboutMe;
      request.fields['currentAddress'] = signupData.currentAddress;

      // Add the files
      // request.files.add(await http.MultipartFile.fromPath(
      //     'profileFile', signupData.profileFile));
      // request.files.add(
      //     await http.MultipartFile.fromPath('coverFile', signupData.coverFile));

      // Send the request
      var response = await request.send();

      // Check the status code
      if (response.statusCode == 200) {
        // Successful signup (201 Created is typical)
        var responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        print('Signup successful: $responseData');
        // Handle the response data
        return true; // Indicate success
      } else if (response.statusCode == 400) {
        // Handle validation errors
        var responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        print('Signup failed: ${response.statusCode}');
        print('Response body: ${responseBody}');
        // Display the specific error messages
        return false; // Indicate failure
      } else {
        // Handle other errors
        var responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        print('Signup failed: ${response.statusCode}');
        print('Response body: ${responseBody}');
        // Display a generic error message
        return false; // Indicate failure
      }
    } catch (e) {
      // Handle network or other errors
      print('Error during signup: $e');
      return false; // Indicate failure
    }
  }

  Future<UserData> fetchUserData(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/users/$userId')); // Use 10.0.2.2 for emulator

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserData.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
