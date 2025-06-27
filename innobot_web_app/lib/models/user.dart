class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final int? age;
  final String? profilePicture;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.age,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      age: json['age'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'age': age,
    };
  }
}
