import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/member2.dart';
import 'package:studyfi/constants.dart';

class ContentsPage extends StatefulWidget {
  const ContentsPage({super.key});

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  final List<String> items = List.generate(10, (index) => "Item ${index + 1}");

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
                  text: "56 Contents",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 10.0, // Horizontal space between items
                    mainAxisSpacing: 10.0, // Vertical space between items
                    childAspectRatio: 1, // Width/height ratio
                  ),
                  padding: EdgeInsets.all(10),
                  itemCount: 8, // Number of items
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      child: Center(
                        child: Text(
                          'Item ${index + 1}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();

          if (result != null) {
            // User picked a file
            String? filePath = result.files.single.path;
            // Do something with the file (open, upload, etc.)
            print('Picked file: $filePath');
          } else {
            // User canceled the picker
            print('No file selected');
          }
        },
        backgroundColor: Constants.dgreen,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
