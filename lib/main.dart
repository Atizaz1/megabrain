import 'package:flutter/material.dart';
import 'package:megabrain/screens/password_recovery.dart';
import 'package:megabrain/screens/personal_information_screen.dart';
import 'package:megabrain/screens/welcome_screen.dart';
import 'package:megabrain/screens/login_screen.dart';
import 'package:megabrain/screens/registration_screen.dart';
import 'package:megabrain/screens/home_screen.dart';

void main() => runApp(MegaBrain());

class MegaBrain extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.grey[100]),
        ),
      ),
      initialRoute: 'welcome_screen',
      routes: {
        'welcome_screen'         : (context) => WelcomeScreen(),
        'login_screen'           : (context) => LoginScreen(), 
        'registration_screen'    : (context) => RegistrationScreen(), 
        'home_screen'            : (context) => HomeScreen(),
        'password_recovery'      : (context) => PasswordVerify(),
        'personal_information'   : (context) => PersonalInformation(),
      },
    );
  }
}
