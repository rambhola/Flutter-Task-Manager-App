import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 🔐 SIGNUP FUNCTION
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService =
      Provider.of<AuthService>(context, listen: false);

      final error = await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (error == null) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const MainScreen()),
              (route) => false,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🧱 BUILD METHOD
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
          const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: isLandscape
                ? Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // LEFT SIDE
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us and start managing your tasks efficiently.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // RIGHT SIDE FORM
                Expanded(
                  flex: 2,
                  child: Column(
                    children: _buildSignUpForm(),
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join us and start managing your tasks.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                ..._buildSignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 FORM WIDGETS
  List<Widget> _buildSignUpForm() {
    return [
      CustomTextField(
        controller: _nameController,
        label: 'Full Name',
        prefixIcon: Icons.person_outline,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Name is required';
          return null;
        },
      ),
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
      CustomTextField(
        controller: _confirmPasswordController,
        label: 'Confirm Password',
        prefixIcon: Icons.lock_outline,
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Confirm your password';
          if (value != _passwordController.text)
            return 'Passwords do not match';
          return null;
        },
      ),
      const SizedBox(height: 32),
      PrimaryButton(
        text: 'Sign Up',
        isLoading: _isLoading,
        onPressed: _signUp,
      ),
      const SizedBox(height: 24),
    ];
  }
}