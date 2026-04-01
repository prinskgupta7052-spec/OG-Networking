import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPdfScreen extends StatefulWidget {
  const UploadPdfScreen({super.key});

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  String selectedCategory = "Networking Basics";
  File? selectedFile;
  bool uploading = false;

  final categories = [
    "Networking Basics",
    "CCNA",
    "Routing & Switching",
    "Protocols",
    "Ports & Services",
    "Network Security",
    "Firewall",
    "Linux Networking",
    "Windows Server",
    "Cyber Security",
    "Interview Questions",
    "Practical Labs",
  ];

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadPdf() async {
    if (selectedFile == null || titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select PDF and enter title")),
      );
      return;
    }

    setState(() => uploading = true);

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref("pdfs/$fileName.pdf");
      await ref.putFile(selectedFile!);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("materials").add({
        "title": titleController.text.trim(),
        "description": descController.text.trim(),
        "category": selectedCategory,
        "type": "pdf",
        "fileUrl": url,
        "time": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF Uploaded Successfully")),
      );

      setState(() {
        selectedFile = null;
        titleController.clear();
        descController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Error: $e")),
      );
    }

    setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload PDF")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategory = val.toString();
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickPdf,
              child: const Text("Select PDF"),
            ),
            const SizedBox(height: 10),
            Text(selectedFile == null
                ? "No file selected"
                : "Selected: ${selectedFile!.path.split('/').last}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploading ? null : uploadPdf,
              child: uploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
