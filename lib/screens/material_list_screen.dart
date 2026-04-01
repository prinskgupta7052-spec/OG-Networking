import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pdf_viewer_screen.dart';
import 'video_player_screen.dart';

class MaterialListScreen extends StatelessWidget {
  final String category;

  const MaterialListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("materials")
            .where("category", isEqualTo: category)
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No material uploaded yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final String title = data["title"] ?? "";
              final String type = data["type"] ?? "";
              final String url = data["fileUrl"] ?? "";

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(type.toUpperCase()),
                  trailing: Icon(
                    type == "pdf" ? Icons.picture_as_pdf : Icons.video_library,
                  ),
                  onTap: () {
                    if (type == "pdf") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(pdfUrl: url),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(videoUrl: url),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
