import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/service_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/loading_widget.dart';
import 'login_screen.dart';
import '../models/user_model.dart' as user_model; // Import with a prefix

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ServiceProvider _serviceProvider = ServiceProvider();
  final ImagePicker _imagePicker = ImagePicker();

  User? _currentUser;
  user_model.UserModel? _userProfile; // Changed to UserModel type
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _serviceProvider.getUserProfile(user.uid);
        setState(() {
          _currentUser = user;
          _userProfile = profile;
          _nameController.text = profile?.name ?? ''; // Access directly
          _phoneController.text = profile?.phone ?? ''; // Access directly
          _addressController.text = profile?.address ?? ''; // Access directly
          _bioController.text = profile?.bio ?? ''; // Access directly
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      String? imageUrl = _userProfile?.profileImage; // Access directly

      // Upload image if selected
      if (_selectedImage != null) {
        // Here you would implement image upload to Firebase Storage
        // For now, we'll just use a placeholder
        imageUrl = 'placeholder_image_url';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserProfile();
      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : _userProfile?.profileImage != null // Access directly
                          ? DecorationImage(
                              image: NetworkImage(_userProfile!.profileImage), // Access directly
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _selectedImage == null && _userProfile?.profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // User Info
          Text(
            _userProfile?.name ?? 'User Name', // Access directly
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile?.email ?? '', // Access directly
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _userProfile?.userType == 'provider' ? 'Service Provider' : 'Service User', // Access directly
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information
        _buildSectionHeader('Personal Information'),
        const SizedBox(height: 16),
        _buildInfoField(
          icon: Icons.person,
          label: 'Full Name',
          controller: _nameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildInfoField(
          icon: Icons.phone,
          label: 'Phone Number',
          controller: _phoneController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildInfoField(
          icon: Icons.location_on,
          label: 'Address',
          controller: _addressController,
          enabled: _isEditing,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildInfoField(
          icon: Icons.info,
          label: 'Bio',
          controller: _bioController,
          enabled: _isEditing,
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // Statistics (for providers)
        if (_userProfile?.userType == 'provider') ...[ // Access directly
          _buildSectionHeader('Statistics'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'Rating',
                  value: '4.8',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.work,
                  title: 'Services',
                  value: '12',
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: 'Customers',
                  value: '48',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Bookings',
                  value: '156',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Settings
        _buildSectionHeader('Settings'),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () {
            // Handle notifications settings
          },
        ),
        _buildSettingsItem(
          icon: Icons.security,
          title: 'Privacy & Security',
          subtitle: 'Account security settings',
          onTap: () {
            // Handle privacy settings
          },
        ),
        _buildSettingsItem(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // Handle help
          },
        ),
        _buildSettingsItem(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            // Handle about
          },
        ),
        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleLogout,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? null : AppTheme.cardColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: _buildProfileHeader(),
                ),
                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildProfileInfo(),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _updateProfile();
          } else {
            setState(() => _isEditing = true);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          _isEditing ? Icons.save : Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}