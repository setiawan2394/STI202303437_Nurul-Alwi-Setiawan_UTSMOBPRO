import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';

class AddPage extends StatefulWidget {
  final Function(JournalNote) onSaved;
  const AddPage({super.key, required this.onSaved});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final titleC = TextEditingController();
  final contentC = TextEditingController();
  DateTime? selectedDateTime;
  File? imageFile;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date == null) return;
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  void _saveNote() {
    if (titleC.text.isEmpty && contentC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Judul atau isi harus diisi")));
      return;
    }

    final note = JournalNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleC.text,
      content: contentC.text,
      dateTime: selectedDateTime ?? DateTime.now(),
      imagePath: imageFile?.path,
    );
    widget.onSaved(note);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ListView(
        children: [
          TextField(
            controller: titleC,
            decoration: const InputDecoration(
              labelText: "Judul",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: contentC,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: "Isi Catatan",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: const Text("Tanggal & Waktu"),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(selectedDateTime == null
                      ? "Belum dipilih"
                      : "${selectedDateTime!.day}-${selectedDateTime!.month}-${selectedDateTime!.year}")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text("Pilih Gambar"),
              ),
              const SizedBox(width: 10),
              if (imageFile != null)
                Image.file(imageFile!,
                    width: 60, height: 60, fit: BoxFit.cover),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saveNote,
            icon: const Icon(Icons.save),
            label: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
