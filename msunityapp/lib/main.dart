import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/events_screen.dart';   // ✅ Import the file
import 'screens/create_event_screen.dart';  // ✅ Import the file
import 'screens/authscreen.dart';  // ✅ Ensure this file exists
import 'services/api_service.dart';
import 'package:msunityapp/screens/create_event_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  final ApiService apiService = ApiService();

  MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event App',
      initialRoute: (token?.isEmpty ?? true) ? '/auth' : '/events',
      routes: {
        "/auth": (context) => AuthScreen(),  
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/events": (context) => EventsScreen(apiService: apiService, token: token ?? ""), // ✅ Correct
        "/create_event": (context) => CreateEventScreen(apiService: apiService, token: token ?? ""), // ✅ Correct
      },
    );
  }
}
