import 'dart:async';

import 'package:classroom_app/model/remotes/classroom_model.dart';
import 'package:classroom_app/model/remotes/file_model.dart';
import 'package:classroom_app/model/remotes/folder_model.dart';
import 'package:classroom_app/model/remotes/message_model.dart';
import 'package:classroom_app/model/remotes/role_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ClassroomService {
  final CollectionReference _classroomCollection = FirebaseFirestore.instance.collection('classrooms');
  Map<String, String> roleCache = {}; // Cache for storing roles
  bool rolesLoaded = false;
// Method to fetch roles from Firestore
  Future<void> fetchRolesOnce() async {
    if (!rolesLoaded) {
      final rolesSnapshot = await FirebaseFirestore.instance.collection('roles').get();

      for (var roleDoc in rolesSnapshot.docs) {
        String roleId = roleDoc.id; // Assuming roleId is the document ID
        String roleName = roleDoc['name']; // Assuming the role name is stored under 'name'
        roleCache[roleId] = roleName;
      }
      rolesLoaded = true; // Mark roles as loaded
    }
  }

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
    // Fetch classrooms based on role and user
    Stream<QuerySnapshot> fetchClassrooms(String roleId, String userId) {
      final collection = FirebaseFirestore.instance.collection('classrooms').orderBy('createdAt', descending: true);

      if (roleId == '1') {
        return collection.snapshots(); // Admin: Get all classrooms
      } else if (roleId == '2') {
        return collection.where('createdByRef', isEqualTo: FirebaseFirestore.instance.doc('users/$userId').path).snapshots(); // Instructor: Created by user
      } else if (roleId == '3') {
        return collection.where('invitedUsersRef', arrayContains: FirebaseFirestore.instance.doc('users/$userId').path).snapshots(); // User: Invited to classrooms
      } else {
        throw Exception('Invalid roleId');
      }
    }

    // Stream transformation with controlled emission
    return fetchClassrooms(roleId, userId).asyncMap((querySnapshot) async {
      // Parse classrooms
      List<ClassroomModel> classroomList = querySnapshot.docs.map((doc) => ClassroomModel.fromMap(doc.data() as Map<String, dynamic>)).toList();

      // Populate additional fields (await ensures complete processing)
      if (context.mounted) {
        await getAllClassroomsCreatorsAndCommentors(classroomList, context);
      }
      if (context.mounted) {
        await getAllFilesSenderAndRole(classroomList, context);
      }
      if (context.mounted) {
        await getAllFoldersCreators(classroomList, context);
      }

      // Only emit the processed list
      return classroomList;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error getting classrooms: $error');
      }
      return []; // Return an empty list in case of an error
    });
  }

  Future<void> getAllFoldersCreators(List<ClassroomModel> classrooms, BuildContext context) async {
    // Map to cache user data and their roles
    Map<String, UserModel> userCache = {};

    for (var classroom in classrooms) {
      if (classroom.folders != null) {
        for (var folder in classroom.folders!) {
          // Check if the folder's creator is already cached
          if (!userCache.containsKey(folder.createdByRef.id)) {
            // Fetch creator data and role from Firestore
            UserModel? creator = await _getUserWithRole(folder.createdByRef.id, userCache);
            if (creator != null) {
              // Cache the creator
              userCache[folder.createdByRef.id] = creator;
            }
          }
          // Assign creator from the cache
          folder.createdBy = userCache[folder.createdByRef.id];
        }
      }
    }
  }

  Future<void> getAllClassroomsCreatorsAndCommentors(List<ClassroomModel> classrooms, BuildContext context) async {
    Map<String, UserModel> userCache = {};

    // Collect all user references (creators, commenters, invited users)
    Set<DocumentReference> userRefs = {};

    for (var classroom in classrooms) {
      userRefs.add(classroom.createdByRef);
      userRefs.addAll(classroom.messages?.map((message) => message.senderRef) ?? []);
      userRefs.addAll(classroom.invitedUsersRef ?? []);
    }

    // Fetch each user with their role and cache them
    for (var userRef in userRefs) {
      await _getUserWithRole(userRef.id, userCache);
    }

    // Assign users from cache
    for (var classroom in classrooms) {
      classroom.createdBy = userCache[classroom.createdByRef.id];
      classroom.invitedUsers = classroom.invitedUsersRef?.map((ref) => userCache[ref.id]).whereType<UserModel>().toList();

      for (MessageModel message in classroom.messages ?? []) {
        message.sender = userCache[message.senderRef.id];
      }
    }
  }

  Future<void> getAllFilesSenderAndRole(List<ClassroomModel> classrooms, BuildContext context) async {
    Map<String, UserModel> userCache = {};

    // Collect all user references from files and messages
    Set<DocumentReference> userRefs = {};
    for (var classroom in classrooms) {
      userRefs.addAll(classroom.files?.map((file) => file.senderRef) ?? []);
      userRefs.addAll(classroom.messages?.map((message) => message.senderRef) ?? []);
    }

    // Fetch users one by one using _getUserWithRole
    for (var ref in userRefs) {
      // Use _getUserWithRole to fetch the user with role, caching as needed
      await _getUserWithRole(ref.id, userCache);
    }

    // Assign users from cache
    for (var classroom in classrooms) {
      for (FileModel file in classroom.files ?? []) {
        file.sender = userCache[file.senderRef.id];
      }

      for (MessageModel message in classroom.messages ?? []) {
        message.sender = userCache[message.senderRef.id];
      }
    }
  }

// Helper method to get user data along with their role
  Future<UserModel?> _getUserWithRole(String uid, Map<String, UserModel> cache) async {
    if (cache.containsKey(uid)) return cache[uid];

    try {
      DocumentSnapshot<Map<String, dynamic>> userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDocument.exists) {
        Map<String, dynamic> userData = userDocument.data()!;
        UserModel user = UserModel.fromMap(userData);

        // Fetch role if exists
        if (userData['roleRef'] != null) {
          DocumentReference roleRef = userData['roleRef'];
          DocumentSnapshot roleSnapshot = await roleRef.get();

          if (roleSnapshot.exists) {
            user.role = RoleModel.fromMap(roleSnapshot.data() as Map<String, dynamic>);
          }
        }

        // Cache the user
        cache[uid] = user;
        return user;
      }
    } catch (e) {
      print("Error fetching user with role: $e");
    }

    return null;
  }

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

  Stream<List<FileModel>> listenToFilesInFolder({
    required ClassroomModel classroom,
    required String? folderId,
    required BuildContext context,
  }) async* {
    final classroomDoc = FirebaseFirestore.instance.collection('classrooms').doc(classroom.id);
    if (folderId != null) {
// Listen to changes in the classroom document
      await for (var snapshot in classroomDoc.snapshots()) {
        if (snapshot.exists) {
          // Convert the snapshot to ClassroomModel
          final classroomData = snapshot.data() as Map<String, dynamic>;
          final classroom = ClassroomModel.fromMap(classroomData);

          // Find the specific folder by folderId
          final folder = classroom.folders?.firstWhere(
            (f) => f.folderId == folderId,
            orElse: () => FolderModel(
              folderId: "",
              colorHex: "",
              folderName: "",
              createdByRef: FirebaseFirestore.instance.doc(''), // Providing a dummy reference
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // If folder exists and contains files, return the files in the folder
          if (folder != null && folder.folderId.isNotEmpty && folder.files != null) {
            await getFilesSenderAndRoleForClassroom(folder, context);
            yield folder.files!; // Yield the files inside the folder

            // Optionally, call your method to update the sender and role
          }
        }
      }
    }
  }

  Future<void> getFilesSenderAndRoleForClassroom(FolderModel folder, BuildContext context) async {
    // Map to cache user data (senders and commentors)
    Map<String, UserModel> userCache = {};

    // Process files and fetch sender data
    if (folder.files != null) {
      for (var file in folder.files!) {
        // Check if the sender is already cached
        if (!userCache.containsKey(file.senderRef.id)) {
          // Fetch sender data and role from Firestore
          UserModel? sender = await _getUserWithRole(file.senderRef.id, userCache);
          if (sender != null) {
            // Cache the sender
            userCache[file.senderRef.id] = sender;
          }
        }
        // Assign sender to the file from the cache
        file.sender = userCache[file.senderRef.id];
      }
    }
  }
}
