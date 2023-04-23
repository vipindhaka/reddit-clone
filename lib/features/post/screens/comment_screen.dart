import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widgets/comment_card.dart';
import 'package:reddit_clone/models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    commentController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);

    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
          data: (post) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PostCard(post: post),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!isGuest)
                      TextField(
                        onSubmitted: (value) => addComment(post),
                        controller: commentController,
                        decoration: const InputDecoration(
                            hintText: 'What are your thoughts',
                            filled: true,
                            border: InputBorder.none),
                      ),
                    ref.watch(getCommentsOfPostProvider(post.id)).when(
                        data: (comments) {
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentCard(
                                  comment: comment,
                                );
                              });
                        },
                        error: (error, stackTrace) {
                          return ErrorText(text: error.toString());
                        },
                        loading: () => const Loader()),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(text: error.toString()),
          loading: () => const Loader()),
    );
  }
}
