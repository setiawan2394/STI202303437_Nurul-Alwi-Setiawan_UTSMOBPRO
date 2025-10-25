import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';

class GalleryPage extends StatelessWidget {
  final List<JournalNote> notes;
  const GalleryPage({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final images = notes.where((n) => n.imagePath != null).toList();
    if (images.isEmpty) {
      return const Center(child: Text("Belum ada gambar tersimpan"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) {
        final n = images[i];
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(n.title),
              content: Image.file(File(n.imagePath!)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup"))
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(n.imagePath!), fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
