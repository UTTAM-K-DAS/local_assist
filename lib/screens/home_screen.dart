import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';
import '../models/user_model.dart' as user_model;
import '../services/auth_service.dart';
import '../services/service_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/loading_widget.dart';
import 'profile_screen.dart';
import 'add_service_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ServiceProvider _serviceProvider = ServiceProvider();
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  User? _currentUser;
  user_model.UserModel? _userProfile;

  final List<String> _serviceCategories = [
    'All',
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Gardening',
    'Appliance Repair',
    'Beauty',
    'Automotive',
    'Tutoring',
    'Pest Control',
    'HVAC',
    'Locksmith',
    'Moving Services',
    'Pet Care',
    'Fitness',
    'Photography',
    'Event Planning',
    'Computer Repair',
    'Home Security',
  ];

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      setState(() {
        _currentUser = user;
      });
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
    });
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      await _loadUserProfile(_currentUser!.uid);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    user_model.UserModel? profile = await _serviceProvider.getUserProfile(uid);
    setState(() {
      _userProfile = profile;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), // Ensure LoginScreen has a const constructor
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void _navigateToAddService() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddServiceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Local Assist',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _navigateToProfile,
          ),
          if (_currentUser == null)
            TextButton(
              onPressed: _navigateToLogin,
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_currentUser != null)
            TextButton(
              onPressed: () async {
                await _authService.signOut();
                _navigateToLogin();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search services...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.smallPadding),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _serviceCategories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallPadding / 2),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = selected ? category : 'All';
                                  });
                                },
                                selectedColor: AppTheme.primaryColor.withOpacity(0.8),
                                labelStyle: TextStyle(
                                  color: _selectedCategory == category ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ServiceModel>>(
                    stream: _serviceProvider.getServices(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No services available.'));
                      }

                      List<ServiceModel> services = snapshot.data!;

                      // Filter services based on search query and category
                      List<ServiceModel> filteredServices = services.where((service) {
                        final matchesSearch = service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            service.description.toLowerCase().contains(_searchQuery.toLowerCase());
                        final matchesCategory = _selectedCategory == 'All' || service.category == _selectedCategory;
                        return matchesSearch && matchesCategory;
                      }).toList();

                      if (filteredServices.isEmpty) {
                        return const Center(child: Text('No services found matching your criteria.'));
                      }

                      return ListView.builder(
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          return ServiceCard(
                            service: service,
                            currentUser: _currentUser,
                            serviceProvider: _serviceProvider,
                            userProfile: _userProfile,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _userProfile?.userType == 'provider'
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddService,
              label: const Text('Add Service'),
              icon: const Icon(Icons.add),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookings', // Or 'Favorites' if you want to show favorites here
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final User? currentUser;
  final ServiceProvider serviceProvider;
  final user_model.UserModel? userProfile; // Pass userProfile to ServiceCard

  const ServiceCard({
    Key? key,
    required this.service,
    this.currentUser,
    required this.serviceProvider,
    this.userProfile,
  }) : super(key: key);

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late Future<bool> _isFavoritedFuture;

  @override
  void initState() {
    super.initState();
    _isFavoritedFuture = _checkFavoriteStatus();
  }

  Future<bool> _checkFavoriteStatus() async {
    if (widget.currentUser != null) {
      return await widget.serviceProvider.isServiceFavorited(
          widget.currentUser!.uid, widget.service.id);
    }
    return false;
  }

  Future<void> _toggleFavorite() async {
    if (widget.currentUser == null) {
      // Show a message to log in to favorite
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to favorite services.')),
      );
      return;
    }
    setState(() {
      _isFavoritedFuture = widget.serviceProvider
          .toggleFavoriteService(widget.currentUser!.uid, widget.service.id)
          .then((_) => _checkFavoriteStatus()); // Re-check status after toggling
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius.topRight.x), // Using x for radius value
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.currentUser != null && widget.userProfile?.userType != 'provider') // Only show favorite button for customers
                  FutureBuilder<bool>(
                    future: _isFavoritedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      bool isFavorited = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleFavorite,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.smallPadding),
            Text(
              widget.service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.smallPadding),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.smallPadding / 2),
                Text(
                  widget.service.category,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: AppTheme.smallPadding / 2),
                Text(
                  '${widget.service.rating.toStringAsFixed(1)} (${widget.service.reviewCount})',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.smallPadding),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.smallPadding / 2),
                Text(
                  '\$${widget.service.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.smallPadding / 2),
                Text(
                  widget.service.location['address'] ?? 'N/A',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.defaultPadding),
            Row(
              children: [
                if (widget.userProfile?.userType != 'provider') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle booking logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.smallPadding),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle view details
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}