import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/news_model.dart';
import 'package:studyfi/models/create_news_model.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewsPage extends StatefulWidget {
  final int groupId;
  final String groupName;

  const NewsPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<NewsModel>> _newsFuture;
  final _headlineController = TextEditingController();
  final _contentController = TextEditingController();
  String? _authorName;
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isUploadingNews = false; // Added to track the news posting state

  @override
  void initState() {
    super.initState();
    _loadNews();
    _loadAuthorName();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthorName() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      try {
        final userData = await _apiService.fetchUserData(userId);
        if (mounted) {
          setState(() {
            _authorName = userData.name;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        // If we couldn't load the author name, set a default
        if (mounted) {
          setState(() {
            _authorName = "Anonymous"; // Default fallback name
          });
        }
      }
    } else {
      // If no userId found, set a default author name
      if (mounted) {
        setState(() {
          _authorName = "Anonymous"; // Default fallback name
        });
      }
    }
  }

  void _loadNews() {
    _newsFuture = _apiService.fetchGroupNews(widget.groupId);
  }

  Future<void> _showAddPhotoDialog(BuildContext context) async {
    // Ensure author name is available
    if (_authorName == null) {
      await _loadAuthorName(); // Try loading again
      if (_authorName == null) {
        // If still null, use a default value
        _authorName = "Anonymous";
      }
    }

    // Reset controllers and image when opening dialog
    _headlineController.clear();
    _contentController.clear();
    setState(() {
      _selectedImage = null;
    });

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Function to pick image inside the dialog
            Future<void> pickImageInDialog() async {
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                // Update both the dialog state and the widget state
                setDialogState(() {
                  _selectedImage = File(pickedFile.path);
                });
                if (mounted) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                  });
                }
              }
            }

            return AlertDialog(
              title: const CustomPoppinsText(
                text: 'Create News Post',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    TextField(
                      controller: _headlineController,
                      decoration: const InputDecoration(
                        labelText: 'Headline',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: pickImageInDialog,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.dgreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_headlineController.text.isEmpty ||
                        _contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    // Validate author name one more time before posting
                    final authorToUse = _authorName ?? "Anonymous";

                    // First close the dialog
                    Navigator.pop(dialogContext);

                    // Then set loading state
                    if (mounted) {
                      setState(() {
                        _isUploadingNews = true;
                      });
                    }

                    try {
                      final success = await _apiService.createNewsPost(
                        CreateNewsModel(
                          headline: _headlineController.text,
                          content: _contentController.text,
                          author: authorToUse,
                          groupIds: [widget.groupId],
                          imageFile: _selectedImage,
                        ),
                      );

                      if (!mounted) return;

                      if (success) {
                        setState(() {
                          _loadNews();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('News post created successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to create news post')),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating news post: $e')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isUploadingNews = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.dgreen,
                  ),
                  child:
                      const Text('Post', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomPoppinsText(
          text: '${widget.groupName} News',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadNews();
          });
        },
        child: FutureBuilder<List<NewsModel>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: CustomPoppinsText(
                  text: 'Error loading news: ${snapshot.error}',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: CustomPoppinsText(
                  text: 'No news available',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final news = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((news.imageUrl?.trim().isNotEmpty ?? false) &&
                          news.imageUrl?.toLowerCase() != 'null' &&
                          Uri.tryParse(news.imageUrl ?? '')?.hasAbsolutePath ==
                              true)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Image.network(
                            news.imageUrl ?? '',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(); // fallback if image load fails
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomPoppinsText(
                              text: news.headline,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 8),
                            CustomPoppinsText(
                              text: 'By ${news.author}',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600] ?? Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            CustomPoppinsText(
                              text: news.content,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploadingNews ? null : () => _showAddPhotoDialog(context),
        backgroundColor: Constants.dgreen,
        shape: const CircleBorder(),
        child: _isUploadingNews
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
