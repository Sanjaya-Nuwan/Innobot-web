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

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<User> users = [];
  int _page = 0;
  int _limit = 5;
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      await _loadUsers();
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
    if (users.length < _limit) return;
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

  Widget _buildUserTable() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Users per page: "),
              DropdownButton<int>(
                value: _limit,
                items: const [5, 10]
                    .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _limit = value;
                      _page = 0;
                    });
                    _loadUsers();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Age')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user.name)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.phone ?? '-')),
                            DataCell(Text(user.address ?? '-')),
                            DataCell(Text(user.age?.toString() ?? '-')),
                            DataCell(
                              Row(
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
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
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
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('Innobot Health'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'User List'),
              Tab(text: 'Add User'),
              Tab(text: 'Other'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(child: _buildUserTable()),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _page == 0 ? null : _prevPage,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text('Page ${_page + 1}'),
                      IconButton(
                        onPressed: users.length < _limit ? null : _nextPage,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: UserFormScreen(onUserCreated: _handleUserCreatedOrUpdated),
            ),
            const Center(child: Text('Other content goes here.')),
          ],
        ),
      ),
    );
  }
}
