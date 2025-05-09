import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/group_content_model.dart';
import 'package:studyfi/models/upload_content_model.dart';
import 'package:studyfi/services/api_service.dart';
// Import for file downloading
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ContentsPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String? groupImageUrl;

  const ContentsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
  });

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  final ApiService apiService = ApiService();
  late Future<List<GroupContent>> contentsFuture;
  bool _isLoading = false;
  // Track downloading state for each content item
  Map<int, bool> _downloadingStates = {};
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _refreshContents();
  }

  Future<void> _refreshContents() async {
    contentsFuture = apiService.fetchGroupContents(widget.groupId);
  }

  // Function to download the file
  Future<void> _downloadFile(GroupContent content) async {
    setState(() {
      _downloadingStates[content.id] = true;
    });

    try {
      // Use app-specific external directory (safe and no permissions needed)
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception("Could not access storage.");

      // Create a folder for your app if you want (optional)
      final downloadDir = Directory('${directory.path}/StudyFiDownloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final fileName =
          "${content.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}";
      final fileExtension = _getFileExtension(content.fileURL);
      final fullFileName = "$fileName$fileExtension";
      final savePath = "${downloadDir.path}/$fullFileName";

      // Download file
      await _dio.download(
        content.fileURL,
        savePath,
        onReceiveProgress: (received, total) {
          // Optional: show progress indicator
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File downloaded to: $savePath"),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(savePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingStates[content.id] = false;
        });
      }
    }
  }

  // Helper function to extract file extension from URL
  String _getFileExtension(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    int lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex != -1) {
      return path.substring(lastDotIndex);
    }
    return '.pdf'; // Default extension if none found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: (widget.groupImageUrl != null &&
                        widget.groupImageUrl!.startsWith('http'))
                    ? NetworkImage(widget.groupImageUrl!)
                    : const AssetImage("assets/group_icon.jpg")
                        as ImageProvider,
              ),
              const SizedBox(height: 12),
              CustomPoppinsText(
                text: widget.groupName,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<GroupContent>>(
                future: contentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                        child: Center(child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    return Expanded(
                      child: Center(
                          child: Text(
                              "Error loading contents: ${snapshot.error}")),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Expanded(
                      child: Center(child: Text("No contents found")),
                    );
                  }

                  final contents = snapshot.data!;
                  return Expanded(
                    child: Column(
                      children: [
                        CustomPoppinsText(
                          text: "${contents.length} Contents",
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1,
                            ),
                            padding: const EdgeInsets.all(10),
                            itemCount: contents.length,
                            itemBuilder: (context, index) {
                              final content = contents[index];
                              return Card(
                                elevation: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.network(
                                              content.fileURL,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons
                                                      .image_not_supported),
                                            ),
                                          ),
                                          // Download button overlay
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    _downloadFile(content),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Constants.dgreen
                                                        .withOpacity(0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: _downloadingStates[
                                                              content.id] ==
                                                          true
                                                      ? const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Icon(
                                                          Icons.download,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      content.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      content.author,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _showUploadDialog,
        backgroundColor: Constants.dgreen,
        shape: const CircleBorder(),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    TextEditingController authorController = TextEditingController();
    File? selectedFile;
    bool fileSelected = false;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a separate context for the dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Upload Content"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: contentController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                    ),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: "Author"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          selectedFile = File(result.files.single.path!);
                          setDialogState(() {
                            fileSelected = true;
                          });
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label:
                          Text(fileSelected ? "File Selected" : "Choose File"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                ElevatedButton(
                  child: const Text("Upload"),
                  onPressed: () async {
                    if (selectedFile != null &&
                        titleController.text.isNotEmpty &&
                        contentController.text.isNotEmpty &&
                        authorController.text.isNotEmpty) {
                      // Before closing dialog, capture the scaffold messenger
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Close dialog first
                      Navigator.pop(dialogContext);

                      // Then set loading state
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final model = UploadContentModel(
                          title: titleController.text,
                          contentText: contentController.text,
                          author: authorController.text,
                          groupId: widget.groupId,
                          file: selectedFile!,
                        );

                        final success =
                            await apiService.uploadGroupContent(model);

                        // Now that the async operation is done, check if widget is still mounted
                        if (!mounted) return;

                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text("Content uploaded successfully")),
                          );
                          await _refreshContents();
                          setState(() {});
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text("Failed to upload content")),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    } else {
                      // Use the dialogContext ScaffoldMessenger for validation errors
                      // while the dialog is still visible
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Please fill all fields and select file")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
