import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name = '';
  String email = '';
  String password = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        centerTitle: true,
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                icon: Icon(Icons.person),
                border: OutlineInputBorder()
                
              ),
              onChanged: (value) => setState(() {
                name = value;
              }),
            
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                icon: Icon(Icons.person),
                border: OutlineInputBorder()
                
              ),
              onChanged: (value) => setState(() {
                name = value;
              }),
            
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Password',
                icon: Icon(Icons.person),
                border: OutlineInputBorder()
                
              ),
              onChanged: (value) => setState(() {
                name = value;
              }),
            
            ),
            SizedBox(height: 16.0),
            
            const Text('you have an account?'),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Login')
            )

          ]
        ),
      ),
    );
  }
}
