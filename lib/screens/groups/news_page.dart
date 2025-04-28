import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/post.dart';
import 'package:studyfi/constants.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  void _showAddPhotoDialog(BuildContext context) {
    final TextEditingController descController = TextEditingController();
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Add Description & Photo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    hintText: 'Enter description',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                pickedImage == null
                    ? TextButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() => pickedImage = image);
                          }
                        },
                        icon: Icon(Icons.image),
                        label: Text('Upload Photo'),
                      )
                    : Column(
                        children: [
                          Image.file(
                            File(pickedImage!.path),
                            height: 100,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => pickedImage = null);
                            },
                            child: Text('Remove Photo'),
                          ),
                        ],
                      ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Use descController.text and pickedImage?.path
                  // Save or process your data here
                  Navigator.of(ctx).pop();
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/group_icon.jpg"),
              ),
              SizedBox(
                height: 12,
              ),
              CustomPoppinsText(
                  text: "Community Helpers",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              SizedBox(
                height: 12,
              ),
              CustomPoppinsText(
                  text: "56 News",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              Expanded(
                child: MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1),
                  itemCount: 10,
                  padding: EdgeInsets.all(10),
                  // Number of items
                  itemBuilder: (context, index) {
                    return Post(
                        imagePath: "assets/post.jpg",
                        description:
                            "Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis.");
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPhotoDialog(context);
        },
        backgroundColor: Constants.dgreen,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
