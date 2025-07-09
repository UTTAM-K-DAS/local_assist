// lib/screens/service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';
import '../utils/error_handler.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserService>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
              ErrorHandler.showInfoSnackBar(context, 'Share feature coming soon!');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(
                Icons.image,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.service.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '\${widget.service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.service.categoryDisplayName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.service.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.service.rating.toStringAsFixed(1)} (${widget.service.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.service.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Consumer<UserService>(
                    builder: (context, userService, child) {
                      final provider = userService.getUserById(widget.service.providerId);
                      
                      if (provider == null) {
                        return const SizedBox();
                      }
                      
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Service Provider',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Text(
                                      provider.name.isNotEmpty ? provider.name[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount})',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Implement contact functionality
                  ErrorHandler.showInfoSnackBar(context, 'Contact feature coming soon!');
                },
                child: const Text('Contact'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.service.isAvailable
                    ? () {
                        // Implement booking functionality
                        ErrorHandler.showInfoSnackBar(context, 'Booking feature coming soon!');
                      }
                    : null,
                child: Text(widget.service.isAvailable ? 'Book Now' : 'Unavailable'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Sign in to your Local Assist account',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
             