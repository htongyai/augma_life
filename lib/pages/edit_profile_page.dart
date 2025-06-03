import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarNameController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _firebaseService.getUserProfile(user.uid);
        if (profile != null) {
          _nameController.text = profile['name'] ?? '';
          _emailController.text = user.email ?? '';
          _avatarNameController.text = profile['avatarName'] ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${e.toString()}'),
          backgroundColor: Colors.red[900],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firebaseService.updateUserProfile(user.uid, {
          'name': _nameController.text.trim(),
          'avatarName': _avatarNameController.text.trim(),
        });

        // Update email if changed
        if (_emailController.text.trim() != user.email) {
          await user.updateEmail(_emailController.text.trim());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red[900],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.red[900]!.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'EDIT PROFILE',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _avatarNameController,
                          label: 'Avatar Name',
                          icon: Icons.face,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an avatar name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.red[900]?.withOpacity(0.5),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      'SAVE CHANGES',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.nunito(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _avatarNameController.dispose();
    super.dispose();
  }
}
