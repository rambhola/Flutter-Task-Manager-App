import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (error == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: isLandscape
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LEFT SIDE
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 80, color: Colors.indigo),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter your details to sign in.',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // RIGHT SIDE (FORM)
                  Expanded(
                    child: Column(
                      children: _buildLoginForm(),
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.check_circle,
                      size: 60, color: Colors.indigo),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter your details to sign in.',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

                  ..._buildLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 FORM WIDGETS
  List<Widget> _buildLoginForm() {
    return [
      CustomTextField(
        controller: _emailController,
        label: 'Email Address',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Email is required';
          if (!value.contains('@'))
            return 'Enter a valid email';
          return null;
        },
      ),
      CustomTextField(
        controller: _passwordController,
        label: 'Password',
        prefixIcon: Icons.lock_outline,
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Password is required';
          if (value.length < 6)
            return 'Password must be at least 6 characters';
          return null;
        },
      ),
      const SizedBox(height: 24),
      PrimaryButton(
        text: 'Log In',
        isLoading: _isLoading,
        onPressed: _login,
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account? "),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SignUpScreen()),
            ),
            child: const Text(
              'Create an account',
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ];
  }
}