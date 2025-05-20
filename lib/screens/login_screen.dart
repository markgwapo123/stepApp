import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? token = await apiService.loginUser(
      _emailController.text,
      _passwordController.text,
      apiService, // 👈 Make sure to pass this if your loginUser expects it
    );

    setState(() {
      _isLoading = false;
    });

    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isAdmin = prefs.getBool("isAdmin") ?? false;

      if (isAdmin) {
        Navigator.pushReplacementNamed(context, "/admin_dashboard"); // 👈 Your admin screen
      } else {
        Navigator.pushReplacementNamed(context, "/events"); // 👈 Normal user screen
      }
    } else {
      setState(() {
        _errorMessage = "Login failed. Please check your credentials.";
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Image.asset(
  'assets/login.jpeg',
  height: 200,
),

              SizedBox(height: 20),
              Text(
                "Welcome to MSUnityApp",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 30),
              Form(
  key: _formKey,
  child: Column(
    children: [
      Container(
        width: 350,
        child: TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "EXAMPLE@EXAMPLE.COM",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your email' : null,
        ),
      ),
      SizedBox(height: 15),
      Container(
        width: 350,
        child: TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "PASSWORD",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your password' : null,
        ),
      ),
      SizedBox(height: 20),
      if (_errorMessage != null)
        Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      SizedBox(height: 20),
      Container(
        width: 350,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  "SIGN IN",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
      SizedBox(height: 10),
      TextButton(
        onPressed: () {},
        child: Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
      SizedBox(height: 20),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: RichText(
          text: TextSpan(
            text: "Don’t have an account? ",
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: "SIGN UP",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
)

            ],
          ),
        ),
      ),
    );
  }
}