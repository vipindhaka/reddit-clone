import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/firebase_options.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:reddit_clone/router.dart';
import 'package:routemaster/routemaster.dart';

import 'theme/pallete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    print(userModel!.name);

    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('here');
    return ref.watch(authStateChangesProvider).when(
        data: (user) => MaterialApp.router(
              title: 'Reddit clone',
              debugShowCheckedModeBanner: false,
              theme: ref.watch(themeNotifierProvider),
              routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                if (user != null && userModel == null) {
                  getData(user);
                }
                if (userModel != null) {
                  userModel = null;
                  return loggedInRoute;
                }
                return loggedOutRoute;
              }),
              routeInformationParser: const RoutemasterParser(),
              //home: const LoginScreen(),
            ),
        error: (error, trace) => ErrorText(text: error.toString()),
        loading: () => const Loader());
  }
}
