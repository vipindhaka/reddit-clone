import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerImage;
  File? avatarImage;
  void selectBannerImage() async {
    XFile? image = await pickImage();
    if (image != null) {
      setState(() {
        bannerImage = File(image.path);
      });
    }
  }

  void selectAvatarImage() async {
    XFile? image = await pickImage();
    if (image != null) {
      setState(() {
        avatarImage = File(image.path);
      });
    }
  }

  void saveCommunity(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        avatar: avatarImage,
        bannerFile: bannerImage,
        context: context,
        community: community);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) => Scaffold(
            appBar: AppBar(
              title: const Text('Edit Community'),
              actions: [
                TextButton(
                  onPressed: () => saveCommunity(community),
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
                                          : community.banner ==
                                                  Constants.bannerDefault
                                              ? const Center(
                                                  child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                ))
                                              : Image.network(
                                                  community.banner)),
                                ),
                              ),
                              Positioned(
                                bottom: 18,
                                left: 20,
                                child: GestureDetector(
                                  onTap: selectAvatarImage,
                                  child: avatarImage != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(avatarImage!),
                                          radius: 35,
                                        )
                                      : CircleAvatar(
                                          radius: 35,
                                          backgroundImage:
                                              NetworkImage(community.avatar),
                                        ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          ),
          error: (error, stackTrace) => ErrorText(text: error.toString()),
          loading: () => const Loader(),
        );
  }
}
