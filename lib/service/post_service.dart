import 'dart:async';
import 'package:classroom_app/model/post_model.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostService {
  final CollectionReference _postCollection = FirebaseFirestore.instance.collection('posts');

  Future<void> addPost(PostModel post) async {
    try {
      // Assign the document ID to the label field
      post.id = _postCollection.doc().id;

      // Add the category to Firestore
      await _postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      debugPrint("Error adding post: $e");
      rethrow;
    }
  }

  Stream<List<PostModel>> getMyPostsAsStream(String userID, BuildContext context) {
    StreamController<List<PostModel>> controller = StreamController<List<PostModel>>();

    FirebaseFirestore.instance.collection('posts').snapshots().listen(
      (querySnapshot) async {
        List<PostModel> postList = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();
          DocumentReference createdByRef = data['createdByRef'];
          if (createdByRef.id == userID) {
            postList.add(PostModel.fromMap(data));
          }
        }
        await getAllPostCreatorsAndCommentors(postList, context);
        controller.add(postList);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error getting posts: $error');
        }
      },
    );

    return controller.stream;
  }

  Stream<List<PostModel>> getAllPostsAsStream(String userID, BuildContext context) {
    StreamController<List<PostModel>> controller = StreamController<List<PostModel>>();

    FirebaseFirestore.instance.collection('posts').snapshots().listen(
      (querySnapshot) async {
        List<PostModel> postList = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();
          // DocumentReference createdByRef = data['createdByRef'];
          // if (createdByRef.id != userID) {
          //   postList.add(PostModel.fromMap(data));
          // }
          postList.add(PostModel.fromMap(data));
        }
        await getAllPostCreatorsAndCommentors(postList, context);
        controller.add(postList);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error getting posts: $error');
        }
      },
    );

    return controller.stream;
  }

  // Update a category
  Future<void> updatePost(PostModel post) async {
    await _postCollection.doc(post.id).update(post.toJson());
  }

// Delete a category
  Future<void> deletePost(String postId) async {
    try {
      await _postCollection.doc(postId).delete();
    } catch (e) {
      debugPrint("Error deleting post: $e");
      rethrow;
    }
  }

  Future<void> getAllPostCreatorsAndCommentors(List<PostModel> posts, BuildContext context) async {
    // Map to cache user data
    Map<String, UserModel> userCache = {};

    // Collect all creators and commenters
    for (var post in posts) {
      // Fetch creator if not already in cache
      if (!userCache.containsKey(post.createdByRef.id)) {
        DocumentSnapshot creatorSnapshot = await post.createdByRef.get();
        if (creatorSnapshot.exists) {
          UserModel creator = UserModel.fromMap(creatorSnapshot.data() as Map<String, dynamic>);
          userCache[post.createdByRef.id] = creator;
        }
      }
      // Assign creator from cache
      post.createdBy = userCache[post.createdByRef.id];

      // Fetch commenters if not already in cache
      for (var comment in post.comments!) {
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
    }
  }
}
