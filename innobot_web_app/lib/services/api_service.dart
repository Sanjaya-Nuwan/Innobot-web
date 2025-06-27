import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/user.dart';
import '../config/dev_config.dart' as config;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static String get baseUrl => config.baseUrl;

  Future<List<User>> fetchUsers({int skip = 0, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/?skip=$skip&limit=$limit'),
    );
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // For mobile/desktop, filePath; for web, pickedFile (PlatformFile)
  Future<User> createUser(
    User user, {
    String? filePath,
    PlatformFile? pickedFile,
  }) async {
    var uri = Uri.parse('$baseUrl/users/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = user.name;
    request.fields['email'] = user.email;
    if (user.phone != null) request.fields['phone'] = user.phone!;
    if (user.address != null) request.fields['address'] = user.address!;
    if (user.age != null) request.fields['age'] = user.age.toString();

    if (kIsWeb && pickedFile != null && pickedFile.bytes != null) {
      final mimeType = lookupMimeType(pickedFile.name);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          pickedFile.bytes!,
          filename: pickedFile.name,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    } else if (!kIsWeb && filePath != null) {
      final mimeType = lookupMimeType(filePath);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<User> updateUser(
    int id,
    User user, {
    String? filePath,
    PlatformFile? pickedFile,
  }) async {
    var uri = Uri.parse('$baseUrl/users/$id');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['name'] = user.name;
    request.fields['email'] = user.email;
    if (user.phone != null) request.fields['phone'] = user.phone!;
    if (user.address != null) request.fields['address'] = user.address!;
    if (user.age != null) request.fields['age'] = user.age.toString();

    if (kIsWeb && pickedFile != null && pickedFile.bytes != null) {
      final mimeType = lookupMimeType(pickedFile.name);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          pickedFile.bytes!,
          filename: pickedFile.name,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    } else if (!kIsWeb && filePath != null) {
      final mimeType = lookupMimeType(filePath);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
