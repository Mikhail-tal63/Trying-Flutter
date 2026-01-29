import 'package:ToDo/presentation/auth/signup_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  bool isLoading = false;

void _login() async{
  setState(() {
    isLoading = true;
  });
await Future.delayed(const Duration(seconds: 2));
  setState(() {
    isLoading = false;
  });
}

void _showMessage(String message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message),
    duration: const Duration(seconds: 2),
    )
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Login'),
      centerTitle: true,
    ),
    body: Padding(padding:
     const EdgeInsets.all(16.0),
     child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
    TextField(decoration: const InputDecoration(
      labelText: 'Email',
      prefixIcon: Icon(Icons.email),
      border: OutlineInputBorder(),
    ),
    onChanged: (value) => setState(() {
      email = value;
    })
    ),
    SizedBox(height: 16.0),
    TextField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder()
      
      ),
      onChanged: (value) => setState(() {
        password = value;
      }),
    ),
      const SizedBox(height: 16.0),

      ElevatedButton(onPressed: (){},
       child: const Text('Login'),
      ),
      const SizedBox(height: 16.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Don\'t have an account?'),
          TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder:
          (context) => const SignupPage()),);
        },
        child: const Text('Sign up'),
        
      )
        ],
      ),
      
      ],      
      )
    )
    );
  }
}