import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:task/screens/contacts.dart';
import 'package:task/services_functions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  runApp(ChangeNotifierProvider(
    create: (context) => ApiService(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SafeArea(child: const ContactsScreen()),
          theme: ThemeData(
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontSize: 24, fontFamily: 'Nunito Bold'),
              bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Nunito Bold'),
              bodySmall: TextStyle(fontSize: 16, fontFamily: 'Nunito Medium'),
            ),
          )),
    );
  }
}
