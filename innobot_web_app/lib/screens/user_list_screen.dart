// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  List<User> users = [];
  int _page = 0;
  final int _limit = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetched = await _apiService.fetchUsers(
        skip: _page * _limit,
        limit: _limit,
      );
      setState(() {
        users = fetched;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleUserCreatedOrUpdated(User user) {
    final index = users.indexWhere((u) => u.id == user.id);
    setState(() {
      if (index >= 0) {
        users[index] = user;
      } else {
        users.insert(0, user);
      }
    });
  }

  Future<void> _deleteUser(int id) async {
    try {
      await _apiService.deleteUser(id);
      setState(() {
        users.removeWhere((u) => u.id == id);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }

  void _nextPage() {
    setState(() {
      _page++;
    });
    _loadUsers();
  }

  void _prevPage() {
    if (_page > 0) {
      setState(() {
        _page--;
      });
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Innobot Health - User List')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: user.profilePicture != null
                            ? Image.network(
                                'http://127.0.0.1:8000/${user.profilePicture}',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: SizedBox(
                          width: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push<User>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserFormScreen(
                                        existingUser: user,
                                        onUserCreated:
                                            _handleUserCreatedOrUpdated,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    _handleUserCreatedOrUpdated(result);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text(
                                        'Delete user "${user.name}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            _deleteUser(user.id!);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back),
              ),
              Text('Page ${_page + 1}'),
              IconButton(
                onPressed: _nextPage,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<User>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserFormScreen(onUserCreated: _handleUserCreatedOrUpdated),
            ),
          );
          if (result != null) {
            _handleUserCreatedOrUpdated(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
