import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';

final storageRepositoryProvider = Provider((ref) {
  return StorageRepository(ref.watch(storageProvider));
});

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository(this._firebaseStorage);

  FutureEither<String> storeFile(
      {required String path, required String id, required File? file}) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask;
      final downloadUlr = await snapshot.ref.getDownloadURL();
      return right(downloadUlr);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
