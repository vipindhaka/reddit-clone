import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerImage;
  File? profileImage;
  late TextEditingController nameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    super.dispose();
  }

  void saveProfile(UserModel user) {
    ref.read(userProfileControllerProvider.notifier).editProfile(
        banner: bannerImage,
        profile: profileImage,
        context: context,
        user: user,
        name: nameController.text.trim());
  }

  void selectBannerImage() async {
    XFile? image = await pickImage();
    if (image != null) {
      setState(() {
        bannerImage = File(image.path);
      });
    }
  }

  void selectprofileImage() async {
    XFile? image = await pickImage();
    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (userModel) => Scaffold(
            appBar: AppBar(
              title: const Text('Edit User Profile'),
              actions: [
                TextButton(
                  onPressed: () => saveProfile(userModel),
                  child: const Text('Save'),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .color!,
                                  child: Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerImage != null
                                          ? Image.file(bannerImage!)
                                          : userModel.banner ==
                                                  Constants.bannerDefault
                                              ? const Center(
                                                  child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                ))
                                              : Image.network(
                                                  userModel.banner)),
                                ),
                              ),
                              Positioned(
                                bottom: 18,
                                left: 20,
                                child: GestureDetector(
                                  onTap: selectprofileImage,
                                  child: profileImage != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(profileImage!),
                                          radius: 35,
                                        )
                                      : CircleAvatar(
                                          radius: 35,
                                          backgroundImage: NetworkImage(
                                              userModel.profilePic),
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Name',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          error: (error, stackTrace) => ErrorText(text: error.toString()),
          loading: () => const Loader(),
        );
  }
}
