import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Modelos/user_profile.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<UserProfile?> getUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserProfile.fromMap(uid, doc.data()!);
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
  }
}
