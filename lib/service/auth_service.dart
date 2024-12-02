import 'package:classroom_app/model/remotes/role_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
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
      'roleRef': user.roleRef,
      'birthDate': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'isDeleted': false,
    });
  }

  // #3 get particular user by id
  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Check if the user document exists
      if (userDocument.exists) {
        // Extract the user data
        Map<String, dynamic> userData = userDocument.data()!;

        // Fetch the role reference from the user document and check if it's null
        DocumentReference? roleRef = userData['roleRef'];

        if (roleRef == null) {
          print("Role reference is null.");
          return null; // Handle the case where roleRef is null (maybe return null or a default role)
        }

        // Fetch the role document from the 'roles' collection
        DocumentSnapshot roleDocument = await roleRef.get();

        // Check if the role document exists
        if (roleDocument.exists) {
          // Safely cast the role data to Map<String, dynamic>
          Map<String, dynamic> roleData = roleDocument.data() as Map<String, dynamic>;

          // Parse the role data into a RoleModel object
          RoleModel role = RoleModel.fromMap(roleData);

          // Map the user data to UserModel and set the fetched role
          UserModel user = UserModel.fromMap(userData);
          user.role = role; // Set the role in the user model

          return user;
        } else {
          print("Role document does not exist.");
          return null; // Role document not found
        }
      } else {
        print("User document does not exist.");
        return null; // User document not found
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null; // Return null in case of an error
    }
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
  Future<void> updateUser(UserModel user, String roleId) async {
    // First, check if the role reference exists in the user model

    // Ensure roleRef is not null
    DocumentReference roleRef = FirebaseFirestore.instance.collection('roles').doc(roleId);

    // Update the user document in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.userId).update({
      'userId': user.userId,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'profilePicture': user.profilePicture,
      'roleRef': roleRef, // Store the role reference
      'birthDate': user.createdAt, // Assuming you are updating this field
      'createdAt': user.createdAt, // Assuming you are updating this field (can be removed if not needed)
      'updatedAt': user.updatedAt,
      'isDeleted': user.isDeleted,
    });
  }

// #6 signout user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
