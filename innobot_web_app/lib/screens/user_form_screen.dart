import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserFormScreen extends StatefulWidget {
  final Function onUserCreated;
  final User? existingUser;
  final TabController tabController;

  const UserFormScreen({
    Key? key,
    required this.onUserCreated,
    required this.tabController,
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
  PlatformFile? pickedFile;

  @override
  void initState() {
    super.initState();
    name = widget.existingUser?.name ?? '';
    email = widget.existingUser?.email ?? '';
    phone = widget.existingUser?.phone;
    address = widget.existingUser?.address;
    age = widget.existingUser?.age;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      //for web - file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pickedFile = result.files.first;
          imageFile = null;
        });
      }
    } else {
      // for mobile/desktop - image_picker
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          imageFile = File(picked.path);
          pickedFile = null;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) return 'Phone must be 10 digits';
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final ageNum = int.tryParse(value);
    if (ageNum == null) return 'Age must be a valid number';
    return null;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final user = User(
        id: widget.existingUser?.id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        age: age,
        profilePicture: widget.existingUser?.profilePicture,
      );

      User resultUser;
      if (widget.existingUser == null) {
        // Create
        resultUser = await _apiService.createUser(
          user,
          filePath: imageFile?.path,
          pickedFile: pickedFile,
        );

        // Reset the form
        _formKey.currentState!.reset();
        setState(() {
          imageFile = null;
          pickedFile = null;
          name = '';
          email = '';
          phone = null;
          address = null;
          age = null;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully!')),
        );
      } else {
        // Update
        if (user.id == null) {
          throw Exception('User ID is null, cannot update');
        }
        resultUser = await _apiService.updateUser(
          user.id!,
          user,
          filePath: imageFile?.path,
          pickedFile: pickedFile,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );

        Navigator.pop(context, resultUser); // only close on update
      }

      widget.onUserCreated(resultUser);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImageSelected = imageFile != null || pickedFile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingUser == null ? 'Create User' : 'Edit User',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                  onSaved: (value) => email = value!,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  onSaved: (value) => phone = value,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => address = value,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: age != null ? age.toString() : '',
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateAge,
                  onSaved: (value) =>
                      age = value!.isEmpty ? null : int.tryParse(value),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Profile Picture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasImageSelected)
                      const Text(
                        'Image selected',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else if (widget.existingUser?.profilePicture != null)
                      const Text(
                        'Using current image',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.existingUser == null ? 'Submit' : 'Update',
                      style: const TextStyle(fontSize: 16),
                    ),
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
