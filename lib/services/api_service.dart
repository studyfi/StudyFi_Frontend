import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/models/comment_model.dart';
import 'package:studyfi/models/group_content_model.dart';
import 'package:studyfi/models/group_count_model.dart';
import 'package:studyfi/models/group_data_model.dart';
import 'package:studyfi/models/group_update_model.dart';
import 'package:studyfi/models/not_joined_group_model.dart';
import 'package:studyfi/models/post_model.dart';
import 'package:studyfi/models/profile_edit_model.dart';
import 'package:studyfi/models/signup_model.dart';
import 'package:studyfi/models/profile_model.dart';
import 'dart:io';

import 'package:studyfi/models/upload_content_model.dart';
import 'package:studyfi/models/news_model.dart';
import 'package:studyfi/models/create_news_model.dart';
import 'package:studyfi/models/notification_model.dart';

enum LoginResult {
  success,
  invalidCredentials,
  unverifiedEmail,
  networkError,
  otherError,
}

class ApiService {
  String baseUrl = "http://192.168.1.100:8080/api/v1";

  Future<LoginResult> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'), // Use your actual endpoint
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // Use your actual content type
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
        return LoginResult.success; // Indicate successful login
      } else {
        final responseData = json.decode(response.body);
        print('Login failed: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (responseData['message'] ==
            "Email address is not verified. Please check your email for the verification code.") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Email address is not verified. Please check your email for the verification code.')),
          );
          return LoginResult.unverifiedEmail; // Indicate unverified email
        } else if (response.statusCode == 401) {
          // Assuming 401 for invalid credentials
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Login failed: ${responseData['message'] ?? 'Invalid credentials'}')),
          );
          return LoginResult.invalidCredentials; // Indicate invalid credentials
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Login failed: ${responseData['message'] ?? response.body}')),
          );
          return LoginResult.otherError; // Indicate other errors
        }
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during login: $e')),
      );
      return LoginResult.networkError; // Indicate network error
    }
  }

  Future<String?> signup(SignupModel signupData, BuildContext context) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/register'), // Use your actual endpoint
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
            // contentType: MediaType('image', 'jpeg'), // specify content type
          ));
        } else {
          print('Profile file does not exist: ${signupData.profileFile}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image file is invalid.')),
          );
          return null; // Return null on failure
        }
      }

      if (signupData.coverFile != null) {
        final coverFile = File(signupData.coverFile!);
        if (await coverFile.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'coverFile',
            signupData.coverFile!,
            // contentType: MediaType('image', 'jpeg'), // You might need to specify content type
          ));
        } else {
          print('Cover file does not exist: ${signupData.coverFile}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover image file is invalid.')),
          );
          return null; // Return null on failure
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming successful signup implies email sent for verification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Signup successful! Please verify your email.')),
        );
        return signupData.email; // Return the email
      } else {
        final responseData = json.decode(responseBody);
        print('Signup failed: ${response.statusCode}');
        print('Response body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Signup failed: ${responseData['message'] ?? 'Invalid data'}')),
        );
        return null; // Return null on failure
      }
    } catch (e) {
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during signup.')),
      );
      return null; // Return null on error
    }
  }

  Future<bool> validateEmailCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/email-verification/validate-email-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Code is valid
      } else {
        // Handle invalid code or other errors
        log('Email validation failed: ${response.statusCode}');
        log('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network or other errors
      log('Error during email validation: $e');
      return false;
    }
  }

  Future<bool> resendEmailCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/email-verification/send-email-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Code resent successfully
      } else {
        // Handle errors
        log('Failed to resend email verification code: ${response.statusCode}');
        log('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network or other errors
      log('Error during email code resend: $e');
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

  Future<List<GroupContent>> fetchGroupContents(int groupId) async {
    final url = Uri.parse('$baseUrl/content/group/$groupId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        if (data == null) return [];

        return data
            .map((item) {
              try {
                return GroupContent.fromJson(item);
              } catch (e) {
                print('Error parsing content item: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .toList()
            .cast<GroupContent>();
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse content data');
      }
    } else {
      print('Failed to fetch group content: ${response.statusCode}');
      throw Exception('Failed to fetch group content');
    }
  }

  Future<bool> uploadGroupContent(UploadContentModel content) async {
    try {
      final uri = Uri.parse('$baseUrl/content/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['title'] = content.title;
      request.fields['contentText'] = content.contentText;
      request.fields['author'] = content.author;
      request.fields['groupIds[]'] = content.groupId.toString();

      // Detect file type
      final mimeType = lookupMimeType(content.file.path)?.split('/');
      if (mimeType == null || mimeType.length != 2) {
        throw Exception("Unable to detect file type");
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        content.file.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));

      // Send the request
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Upload success: ${responseData.body}");
        return true;
      } else {
        print(
            "Upload failed: ${responseData.statusCode} - ${responseData.body}");
        return false;
      }
    } catch (e) {
      print("Exception while uploading content: $e");
      return false;
    }
  }

  Future<List<NewsModel>> fetchGroupNews(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/group/$groupId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        print('Failed to fetch group news: ${response.statusCode}');
        throw Exception('Failed to fetch group news');
      }
    } catch (e) {
      print('Error fetching group news: $e');
      throw Exception('Failed to fetch group news: $e');
    }
  }

  Future<bool> createNewsPost(CreateNewsModel news) async {
    if (!news.isValid()) {
      throw Exception('Invalid news post data');
    }
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/news/post'),
      );

      // Add form fields
      request.fields['headline'] = news.headline;
      request.fields['contentText'] = news.content;
      request.fields['author'] = news.author;

      for (var id in news.groupIds) {
        request.fields['groupIds[]'] = id.toString();
      }

      // Add image file if exists
      if (news.imageFile != null && await news.imageFile!.exists()) {
        final mimeType = lookupMimeType(news.imageFile!.path)?.split('/');
        if (mimeType != null && mimeType.length == 2) {
          request.files.add(await http.MultipartFile.fromPath(
            'imageFile', // 'file' should match your backend's expected parameter name
            news.imageFile!.path,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ));
        }
      }

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('News post created successfully: $responseBody');
        return true;
      } else {
        print('Failed to create news post: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error creating news post: $e');
      return false;
    }
  }

  Future<GroupCountModel> fetchGroupCounts(int groupId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/groups/$groupId/counts'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return GroupCountModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load group counts');
    }
  }

  Future<List<UserData>> fetchGroupMembers(int groupId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/groups/$groupId/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => UserData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch group members');
    }
  }

  Future<List<NotificationModel>> fetchNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/getnotifications/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> unreadNotifications =
            jsonResponse['unreadNotifications'] ?? [];
        final List<dynamic> readNotifications =
            jsonResponse['readNotifications'] ?? [];
        final List<dynamic> allNotifications = [
          ...unreadNotifications,
          ...readNotifications
        ];

        return allNotifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'verificationCode': responseData['verificationCode'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send reset code. Please try again.',
        };
      }
    } catch (e) {
      print('Error during forgot password request: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'verificationCode': verificationCode,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Password reset successful',
          };
        } catch (e) {
          return {
            'success': true,
            'message': response.body, // fallback to plain text
          };
        }
      } else {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to reset password',
          };
        } catch (e) {
          return {
            'success': false,
            'message': response.body, // fallback for non-JSON errors too
          };
        }
      }
    } catch (e) {
      print('Error during password reset: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<List<GroupData>> fetchUserGroups(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((jsonItem) => GroupData.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching groups: $e');
      throw e;
    }
  }

  Future<bool> leaveGroup(int groupId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/groups/remove/$groupId/user/$userId'),
      );

      if (response.statusCode == 200) {
        print('Successfully left the group');
        return true;
      } else {
        print('Failed to leave group: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error leaving group: $e');
      return false;
    }
  }

  Future<bool> markNotificationAsRead(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/markallasread/$userId'),
      );

      if (response.statusCode == 200) {
        print('Successfully marked all notifications as read');
        return true;
      } else {
        print(
            'Failed to mark all notifications as read: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> updateGroupInfo(int groupId, GroupUpdateModel model) async {
    try {
      var uri = Uri.parse('$baseUrl/groups/update/$groupId');
      var request = http.MultipartRequest('PUT', uri);

      request.fields['name'] = model.name;
      request.fields['description'] = model.description;

      if (model.imageFilePath != null) {
        final file = File(model.imageFilePath!);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            model.imageFilePath!,
          ));
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to update group: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error updating group: $e');
      return false;
    }
  }

  // Fetch posts for a group
  Future<List<Post>> fetchGroupPosts(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/groups/$groupId/posts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        print('Failed to load posts. Status code: ${response.statusCode}');
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Failed to load posts: $e');
    }
  }

// Create a new post
  Future<bool> createPost(int groupId, String content) async {
    try {
      // Get the user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/groups/$groupId/posts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
          'user': {'id': userId}
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create post. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

// Like a post
  Future<bool> likePost(int postId) async {
    try {
      // Get the user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/posts/$postId/likes'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to like post. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  Future<bool> unlikePost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/chats/posts/$postId/likes?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to unlike post. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error unliking post: $e');
      return false;
    }
  }

// Add a comment to a post
  Future<bool> commentOnPost(int postId, String content) async {
    try {
      // Get the user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
          'user': {'id': userId}
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add comment. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  // Method to fetch comments for a post
  Future<List<Comment>> fetchPostComments(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/posts/$postId/comments'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        print('Failed to fetch comments: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchPostLikes(int postId) async {
    try {
      // Get the user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/chats/posts/$postId/likes?currentUserId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return {
          'likeCount': jsonData['likeCount'] as int,
          'likedUsers': (jsonData['likedUsers'] as List)
              .map((user) => PostUser.fromJson(user))
              .toList(),
          'likedByCurrentUser': jsonData['likedByCurrentUser'] as bool,
        };
      } else {
        print('Failed to fetch likes. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch likes');
      }
    } catch (e) {
      print('Error fetching likes: $e');
      throw Exception('Failed to fetch likes: $e');
    }
  }
}
