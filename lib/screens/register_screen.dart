import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() => isLoading = true);
                final user = await auth.register(emailController.text, passwordController.text);
                setState(() => isLoading = false);
                if (user != null) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
                }
              },
              child: isLoading ? const CircularProgressIndicator() : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
