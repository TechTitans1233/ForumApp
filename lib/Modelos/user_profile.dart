class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String imageUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.imageUrl,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'imageUrl': imageUrl,
    };
  }
}
