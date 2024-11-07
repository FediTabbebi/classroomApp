import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationServices {
  final _firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // #1 login
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return await getCurrentUser(authResult.user!.uid);
  }

  // #2 register
  Future<void> registerUser({required UserModel user, String? profilePicture}) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    final User currentUser = userCredential.user!;

    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
      'userId': currentUser.uid,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'profilePicture': profilePicture,
      'role': user.role,
      'birthDate': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'isDeleted': false,
    });
  }

  // #3 get particular user by id
  Future<UserModel?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDocument.exists) {
      return UserModel.fromMap(userDocument.data()!);
    }
    return null;
  }

  // #4 get current authenticated user (no id needed)
  Future<UserModel?> getAuthUser() async {
    User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      UserModel? user = await getCurrentUser(firebaseUser.uid);
      return user;
    } else {
      return null;
    }
  }

// #5 update user
  Future<void> updateUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.userId).update({
      'userId': user.userId,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'profilePicture': user.profilePicture,
      'role': user.role,
      'birthDate': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'isDeleted': user.isDeleted,
    });
  }

// #6 signout user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
