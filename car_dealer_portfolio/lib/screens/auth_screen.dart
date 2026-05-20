import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const AuthScreen({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int selectedTab = 0;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool rememberMe = true;
  bool agreeTerms = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchTab(int tab) {
    setState(() {
      selectedTab = tab;
      hidePassword = true;
      hideConfirmPassword = true;
    });
  }

  Future<void> _saveUserProfile(User user, {String? name, String? phone}) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    final userName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : user.displayName ?? 'User';

    final userPhone = phone?.trim().isNotEmpty == true
        ? phone!.trim()
        : phoneController.text.trim();

    final data = {
      'uid': user.uid,
      'name': userName,
      'email': user.email,
      'phone': userPhone,
      'photoUrl': user.photoURL,
      'provider': user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'email',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      await userRef.set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.update(data);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _saveUserProfile(user);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign in successful')),
        );

        widget.onLoginSuccess?.call();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google sign in failed');
    } catch (_) {
      _showError('Google sign in failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _signInWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await _saveUserProfile(user);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in successful')),
        );

        widget.onLoginSuccess?.call();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Sign in failed');
    } catch (_) {
      _showError('Sign in failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _registerWithEmail() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (!email.contains('@')) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    if (!agreeTerms) {
      _showError('Please agree to Terms & Privacy Policy');
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();

        final updatedUser = _auth.currentUser ?? user;

        await _saveUserProfile(
          updatedUser,
          name: name,
          phone: phone,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );

        widget.onLoginSuccess?.call();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('This email is already registered. Please sign in.');
      } else if (e.code == 'weak-password') {
        _showError('The password is too weak.');
      } else if (e.code == 'invalid-email') {
        _showError('Please enter a valid email address.');
      } else {
        _showError(e.message ?? 'Registration failed');
      }
    } catch (_) {
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email first');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to send reset email');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedTab == 0
                        ? 'Sign in to continue'
                        : 'Create your account to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _AuthTab(
                        title: 'Sign In',
                        selected: selectedTab == 0,
                        onTap: () => _switchTab(0),
                      ),
                      _AuthTab(
                        title: 'Register',
                        selected: selectedTab == 1,
                        onTap: () => _switchTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: selectedTab == 0 ? _buildSignIn() : _buildRegister(),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn() {
    return Column(
      children: [
        _InputField(
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _InputField(
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          controller: passwordController,
          obscureText: hidePassword,
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => hidePassword = !hidePassword),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              activeColor: const Color(0xFF1A73E8),
              onChanged: (value) {
                setState(() => rememberMe = value ?? false);
              },
            ),
            const Text('Remember me'),
            const Spacer(),
            TextButton(
              onPressed: isLoading ? null : _resetPassword,
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          title: 'Sign In',
          onTap: isLoading ? null : _signInWithEmail,
        ),
        const SizedBox(height: 20),
        const _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          title: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onTap: isLoading ? null : _signInWithGoogle,
        ),
      ],
    );
  }

  Widget _buildRegister() {
    return Column(
      children: [
        _InputField(
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          controller: nameController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _InputField(
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _InputField(
          label: 'Phone Number',
          hint: 'Enter phone number',
          icon: Icons.phone_outlined,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _InputField(
          label: 'Password',
          hint: 'Create password',
          icon: Icons.lock_outline,
          controller: passwordController,
          obscureText: hidePassword,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => hidePassword = !hidePassword),
          ),
        ),
        const SizedBox(height: 16),
        _InputField(
          label: 'Confirm Password',
          hint: 'Confirm password',
          icon: Icons.lock_outline,
          controller: confirmPasswordController,
          obscureText: hideConfirmPassword,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              hideConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() => hideConfirmPassword = !hideConfirmPassword);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: agreeTerms,
              activeColor: const Color(0xFF1A73E8),
              onChanged: (value) {
                setState(() => agreeTerms = value ?? false);
              },
            ),
            Expanded(
              child: Text(
                'I agree to Terms & Privacy Policy',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          title: 'Create Account',
          onTap: isLoading ? null : _registerWithEmail,
        ),
        const SizedBox(height: 20),
        const _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          title: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onTap: isLoading ? null : _signInWithGoogle,
        ),
      ],
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _AuthTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? const Color(0xFF1A73E8) : Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 3,
              color: selected ? const Color(0xFF1A73E8) : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A73E8),
        disabledBackgroundColor: Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black87, size: 30),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}
