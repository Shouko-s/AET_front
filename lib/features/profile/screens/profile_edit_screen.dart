import 'package:flutter/material.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:aet_app/core/constants/color_constants.dart';

class ProfileEditScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  const ProfileEditScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _emailChangeRequested = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _emailController.text = widget.currentEmail;
  }

  Future<void> _updateName() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    final result = await _authService.updateName(_nameController.text.trim());
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _successMessage = 'Name updated successfully!';
      } else {
        _errorMessage = result['message'] ?? 'Failed to update name';
      }
    });
  }

  Future<void> _requestEmailChange() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    final result = await _authService.requestEmailChange(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _emailChangeRequested = true;
        _successMessage = 'Verification code sent to new email!';
      } else {
        _errorMessage = result['message'] ?? 'Failed to request email change';
      }
    });
  }

  Future<void> _confirmEmailChange() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    final result = await _authService.confirmEmailChange(
      _emailController.text.trim(),
      _codeController.text.trim(),
    );
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _successMessage = 'Email updated successfully!';
        _emailChangeRequested = false;
      } else {
        _errorMessage = result['message'] ?? 'Failed to confirm email change';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallFontSize = screenWidth * 0.04;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: ColorConstants.backgroundColor,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: ColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Change Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: smallFontSize + 2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Name'),
              ),
              const SizedBox(height: 32),
              Text(
                'Change Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: smallFontSize + 2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _requestEmailChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Request Email Change'),
              ),
              if (_emailChangeRequested) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmEmailChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Confirm Email Change'),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: ColorConstants.errorColor),
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _successMessage!,
                  style: TextStyle(color: ColorConstants.successColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
