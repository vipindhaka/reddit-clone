import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/utils.dart';
import '../../../models/post_model.dart';
import '../repository/user_profile_repository.dart';
import 'package:fpdart/fpdart.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(userProfileRepository, storageRepository, ref);
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepositoryProvider;
  final Ref _ref;

  UserProfileController(
      this._userProfileRepository, this._storageRepositoryProvider, this._ref)
      : super(false);

  void editProfile({
    required File? banner,
    required File? profile,
    required BuildContext context,
    required UserModel user,
    required String name,
  }) async {
    if (name.isEmpty) {
      showSnackBar(context, 'Name Cannot be Empty');
      return;
    } else {
      user = user.copyWith(name: name);
    }
    state = true;
    if (profile != null) {
      final res = await _storageRepositoryProvider.storeFile(
          path: 'users/profile', id: user.uid, file: profile);

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (banner != null) {
      final res = await _storageRepositoryProvider.storeFile(
          path: 'users/banner', id: user.uid, file: banner);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => user = user.copyWith(banner: r));
    }
    final res = await _userProfileRepository.editProfile(user);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
