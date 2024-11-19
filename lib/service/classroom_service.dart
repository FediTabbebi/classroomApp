import 'dart:async';

import 'package:classroom_app/model/classroom_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/model/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ClassroomService {
  final CollectionReference _classroomCollection = FirebaseFirestore.instance.collection('classrooms');

  Future<void> addClassroom(ClassroomModel classroom) async {
    try {
      // Assign the document ID to the label field
      classroom.id = _classroomCollection.doc().id;

      // Add the classroom to Firestore
      await _classroomCollection.doc(classroom.id).set(classroom.toJson());
    } catch (e) {
      debugPrint("Error adding classroom: $e");
      rethrow;
    }
  }

  Stream<List<ClassroomModel>> getAllClassroomAsStream(String roleId, String userId, BuildContext context) {
    StreamController<List<ClassroomModel>> controller = StreamController<List<ClassroomModel>>();

    FirebaseFirestore.instance.collection('classrooms').orderBy('createdAt', descending: true).snapshots().listen(
      (querySnapshot) async {
        List<ClassroomModel> classroomList = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();

          // Parse ClassroomModel from the document data
          ClassroomModel classroom = ClassroomModel.fromMap(data);

          // Filter based on the role
          if (roleId == '1') {
            // Admin: Get all classrooms
            classroomList.add(classroom);
          } else if (roleId == '2' && classroom.createdByRef.id == userId) {
            // Instructor: Get classrooms where createdByRef matches userId
            classroomList.add(classroom);
          } else if (roleId == '3' && classroom.invitedUsersRef?.any((ref) => ref.id == userId) == true) {
            // User: Get classrooms where invitedUsersRef contains userId
            classroomList.add(classroom);
          }
        }

        // Optional: Populate additional fields if needed (including file sender references)
        await getAllClassroomsCreatorsAndCommentors(classroomList, context);
        await getAllFilesSenderAndRole(classroomList, context);

        // Add the list to the stream
        controller.add(classroomList);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error getting classrooms: $error');
        }
        controller.addError(error);
      },
    );

    return controller.stream;
  }

  Future<void> getAllClassroomsCreatorsAndCommentors(List<ClassroomModel> classrooms, BuildContext context) async {
    // Map to cache user data
    Map<String, UserModel> userCache = {};

    // Collect all creators, commenters, and invited users
    for (var classroom in classrooms) {
      // Fetch creator if not already in cache
      if (!userCache.containsKey(classroom.createdByRef.id)) {
        DocumentSnapshot creatorSnapshot = await classroom.createdByRef.get();
        if (creatorSnapshot.exists) {
          UserModel creator = UserModel.fromMap(creatorSnapshot.data() as Map<String, dynamic>);
          userCache[classroom.createdByRef.id] = creator;
        }
      }
      // Assign creator from cache
      classroom.createdBy = userCache[classroom.createdByRef.id];

      // Fetch commenters if not already in cache
      for (var comment in classroom.comments!) {
        if (!userCache.containsKey(comment.commentedByRef.id)) {
          DocumentSnapshot commentorSnapshot = await comment.commentedByRef.get();
          if (commentorSnapshot.exists) {
            UserModel commentor = UserModel.fromMap(commentorSnapshot.data() as Map<String, dynamic>);
            userCache[comment.commentedByRef.id] = commentor;
          }
        }
        // Assign commenter from cache
        comment.commentedBy = userCache[comment.commentedByRef.id];
      }

      // Fetch invited users if not already in cache
      if (classroom.invitedUsersRef != null) {
        List<UserModel> invitedUsers = [];
        for (var userRef in classroom.invitedUsersRef!) {
          if (!userCache.containsKey(userRef.id)) {
            DocumentSnapshot userSnapshot = await userRef.get();
            if (userSnapshot.exists) {
              UserModel user = UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
              userCache[userRef.id] = user;
              invitedUsers.add(user);
            }
          } else {
            invitedUsers.add(userCache[userRef.id]!); // Add from cache
          }
        }
        // Assign the invited users to the classroom model
        classroom.invitedUsers = invitedUsers;
      }
    }
  }

  Future<void> getAllFilesSenderAndRole(List<ClassroomModel> classrooms, BuildContext context) async {
    // Map to cache user data (senders and commentors)
    Map<String, UserModel> userCache = {};

    for (var classroom in classrooms) {
      // Process files and fetch sender data
      if (classroom.files != null) {
        for (var file in classroom.files!) {
          // Check if the sender is already cached
          if (!userCache.containsKey(file.senderRef.id)) {
            // Fetch sender data and role from Firestore
            UserModel? sender = await _getUserWithRole(file.senderRef.id);
            if (sender != null) {
              // Cache the sender
              userCache[file.senderRef.id] = sender;
            }
          }
          // Assign sender to the file from the cache
          file.sender = userCache[file.senderRef.id];
        }
      }

      // Process comments and assign commentor role
      if (classroom.comments != null) {
        for (var comment in classroom.comments!) {
          // Check if the commentor is already cached
          if (!userCache.containsKey(comment.commentedByRef.id)) {
            // Fetch commentor data and role from Firestore
            UserModel? commentor = await _getUserWithRole(comment.commentedByRef.id);
            if (commentor != null) {
              // Cache the commentor
              userCache[comment.commentedByRef.id] = commentor;
            }
          }
          // Assign commentor to the comment model from the cache
          comment.commentedBy = userCache[comment.commentedByRef.id];
        }
      }

      // Process invited users and add roles (if any)
      if (classroom.invitedUsersRef != null) {
        List<UserModel> invitedUsers = [];
        for (var userRef in classroom.invitedUsersRef!) {
          // Check if the user is already cached
          if (!userCache.containsKey(userRef.id)) {
            // Fetch user data and role from Firestore
            UserModel? user = await _getUserWithRole(userRef.id);
            if (user != null) {
              // Cache the user
              userCache[userRef.id] = user;
              invitedUsers.add(user);
            }
          } else {
            // If the user is already cached, just add them to the invited list
            invitedUsers.add(userCache[userRef.id]!);
          }
        }
        // Assign the invited users to the classroom model
        classroom.invitedUsers = invitedUsers;
      }
    }
  }

// Helper method to get user data along with their role
  Future<UserModel?> _getUserWithRole(String uid) async {
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

          // Parse the role data into a UserRole object
          UserRole role = UserRole.fromMap(roleData);

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
  // Update a classroom

  Future<void> updateClassroom(ClassroomModel classroom) async {
    await _classroomCollection.doc(classroom.id).update(classroom.toJson());
  }

// Delete a classroom
  Future<void> deleteclassroom(String classroomId) async {
    try {
      await _classroomCollection.doc(classroomId).delete();
    } catch (e) {
      debugPrint("Error deleting classroom: $e");
      rethrow;
    }
  }
}
