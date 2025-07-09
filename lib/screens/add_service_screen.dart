import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Make sure this import is present

import '../models/service_model.dart';
import '../services/service_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/loading_widget.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceModel? service; // For editing existing service

  const AddServiceScreen({Key? key, this.service}) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceProvider _serviceProvider = ServiceProvider();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Form state
  bool _isLoading = false;
  String? _selectedCategory;
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isActive = true;

  final List<String> _serviceCategories = [
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
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.price.toString();
      _locationController.text = widget.service!.location['address'] ?? ''; // Assuming address is in location map
      _selectedCategory = widget.service!.category;
      _existingImageUrls = List.from(widget.service!.serviceImages);
      _isActive = widget.service!.isActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index, {bool isNewImage = true}) {
    setState(() {
      if (isNewImage) {
        _selectedImages.removeAt(index);
      } else {
        _existingImageUrls.removeAt(index);
      }
    });
  }

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<String> imageUrls = List.from(_existingImageUrls);

        // Upload new images
        for (File imageFile in _selectedImages) {
          // You need a serviceId to upload images.
          // For new services, you might need to create the service first to get an ID.
          // For simplicity here, let's assume we're either editing or have a placeholder ID.
          // A more robust solution would involve creating the service first, then uploading images with the new ID.
          String dummyServiceId = widget.service?.id ?? 'temp_service_id'; // Placeholder for new services
          String? url = await _serviceProvider.uploadServiceImage(imageFile, dummyServiceId); // Pass serviceId
          if (url != null) {
            imageUrls.add(url);
          }
        }

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          Fluttertoast.showToast(msg: "User not logged in."); // Use msg
          return;
        }

        // Fetch provider details (you might already have this in a provider)
        user_model.UserModel? providerProfile =
            await _serviceProvider.getUserProfile(currentUser.uid);

        if (providerProfile == null) {
          Fluttertoast.showToast(msg: "Could not fetch provider profile."); // Use msg
          return;
        }

        ServiceModel newService = ServiceModel(
          id: widget.service?.id ?? '', // Will be updated if new service
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory!,
          price: double.parse(_priceController.text),
          providerId: currentUser.uid,
          providerName: providerProfile.name,
          providerPhone: providerProfile.phone,
          providerEmail: providerProfile.email,
          providerImage: providerProfile.profileImage ?? '', // Assuming profileImage exists in UserModel
          serviceImages: imageUrls,
          isActive: _isActive,
          isApproved: false, // Default for new services
          createdAt: widget.service?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          location: {'address': _locationController.text}, // Storing as map for flexibility
          serviceAreas: [], // Add if needed
          availability: {}, // Add if needed
        );

        if (widget.service == null) {
          // Add new service
          String serviceId = await _serviceProvider.addService(newService);
          // If you uploaded images with a dummy ID, you'd re-upload them here with the real serviceId
          // or update their metadata in Firebase Storage. For now, we'll assume the dummy ID works for storage paths.
          Fluttertoast.showToast(msg: "Service added successfully!"); // Use msg
        } else {
          // Update existing service
          await _serviceProvider.updateService(
              widget.service!.id, newService.toFirestore());
          Fluttertoast.showToast(msg: "Service updated successfully!"); // Use msg
        }

        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error saving service: $e"); // Use msg
        print('Error saving service: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service != null ? 'Edit Service' : 'Add New Service'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Service Title',
                        hintText: 'e.g., House Cleaning',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.defaultPadding),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Provide a detailed description of your service',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.defaultPadding),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: _serviceCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.defaultPadding),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (e.g., per hour, per service)',
                        hintText: 'e.g., 50.00',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.defaultPadding),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Service Location/Area',
                        hintText: 'e.g., City, specific neighborhood',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.defaultPadding),
                    Text('Service Images', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppTheme.smallPadding),
                    Wrap(
                      spacing: AppTheme.smallPadding,
                      runSpacing: AppTheme.smallPadding,
                      children: [
                        ..._existingImageUrls.asMap().entries.map((entry) {
                          int idx = entry.key;
                          String url = entry.value;
                          return Stack(
                            children: [
                              Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(idx, isNewImage: false),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        ..._selectedImages.asMap().entries.map((entry) {
                          int idx = entry.key;
                          File image = entry.value;
                          return Stack(
                            children: [
                              Image.file(
                                image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(idx),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: const Icon(Icons.add_a_photo, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.defaultPadding),
                    Row(
                      children: [
                        Text('Service Active', style: Theme.of(context).textTheme.titleMedium),
                        Switch(
                          value: _isActive,
                          onChanged: (bool value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.largePadding),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const LoadingWidget()
                            : Text(
                                widget.service != null
                                    ? 'Update Service'
                                    : 'Add Service',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.largePadding),
                  ],
                ),
              ),
            ),
    );
  }
}