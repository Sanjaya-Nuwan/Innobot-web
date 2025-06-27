// lib/screens/user_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserFormScreen extends StatefulWidget {
  final Function onUserCreated;
  final User? existingUser;

  const UserFormScreen({
    Key? key,
    required this.onUserCreated,
    this.existingUser,
  }) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  late String name;
  late String email;
  String? phone;
  String? address;
  int? age;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing user data
    name = widget.existingUser?.name ?? '';
    email = widget.existingUser?.email ?? '';
    phone = widget.existingUser?.phone;
    address = widget.existingUser?.address;
    age = widget.existingUser?.age;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final user = User(
        id: widget.existingUser?.id, // keep nullable
        name: name,
        email: email,
        phone: phone,
        address: address,
        age: age,
        profilePicture: widget.existingUser?.profilePicture,
      );

      User resultUser;
      if (widget.existingUser == null) {
        // Create mode
        resultUser = await _apiService.createUser(user, imageFile?.path);
      } else {
        // Update mode - ensure id is not null
        if (user.id == null) {
          throw Exception('User ID is null, cannot update');
        }
        resultUser = await _apiService.updateUser(
          user.id!,
          user,
          imageFile?.path,
        );
      }

      widget.onUserCreated(resultUser);
      Navigator.pop(context, resultUser);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingUser == null ? 'Create User' : 'Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => name = value!,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Enter valid email'
                      : null,
                  onSaved: (value) => email = value!,
                ),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => phone = value,
                ),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: 'Address'),
                  onSaved: (value) => address = value,
                ),
                TextFormField(
                  initialValue: age != null ? age.toString() : '',
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      age = value!.isEmpty ? null : int.tryParse(value),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Profile Picture'),
                    ),
                    const SizedBox(width: 10),
                    if (imageFile != null) const Text('Image selected'),
                    if (imageFile == null &&
                        widget.existingUser?.profilePicture != null)
                      const Text('Current image exists'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    widget.existingUser == null ? 'Submit' : 'Update',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
