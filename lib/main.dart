import 'package:flutter/material.dart';
import 'package:flutter_web_rtc/models/user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_rtc/services/auth.dart';
import 'screens/wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  final user = AuthService().user;

  @override
  Widget build(BuildContext context) {
    print(user);
    return StreamProvider<UserModal>.value(
        value: AuthService().user,
        child: MaterialApp(
        home: Wrapper()
      ),
    );
  }
}
