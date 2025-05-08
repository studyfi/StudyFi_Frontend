import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/group_update_model.dart';
import 'package:studyfi/services/api_service.dart';

class EditGroupInfoPage extends StatefulWidget {
  final int groupId;
  final String initialName;
  final String initialDescription;
  final String? initialImagePath;

  const EditGroupInfoPage({
    super.key,
    required this.groupId,
    required this.initialName,
    required this.initialDescription,
    this.initialImagePath,
  });

  @override
  State<EditGroupInfoPage> createState() => _EditGroupInfoPageState();
}

class _EditGroupInfoPageState extends State<EditGroupInfoPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _descriptionController.text = widget.initialDescription;
    _existingImageUrl = widget.initialImagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _existingImageUrl = null; // Remove old image preview
      });
    }
  }

  Future<void> _saveGroupInfo() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and description are required.')),
      );
      return;
    }

    final model = GroupUpdateModel(
      name: _nameController.text,
      description: _descriptionController.text,
      imageFilePath: _imageFile?.path,
    );

    final success = await _apiService.updateGroupInfo(widget.groupId, model);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group info updated successfully')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update group info')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_existingImageUrl != null &&
                                    _existingImageUrl!.isNotEmpty)
                                ? NetworkImage(_existingImageUrl!)
                                : const AssetImage("assets/group_icon.jpg")
                                    as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Constants.dgreen,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CustomPoppinsText(
                  text: "Name:",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Community Helpers",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 12),
                CustomPoppinsText(
                  text: "Description:",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Group description...",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Button2(
                    buttonText: "Save",
                    onTap: _saveGroupInfo,
                    buttonColor: Constants.dgreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
