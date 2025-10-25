import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../utils/storage.dart';
import '../widgets/note_card.dart';
import 'add_page.dart';
import 'gallery_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<JournalNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageHelper.loadNotes();
    setState(() => _notes = notes);
  }

  Future<void> _delete(JournalNote n) async {
    _notes.removeWhere((note) => note.id == n.id);
    await StorageHelper.saveNotes(_notes);
    setState(() {});
  }

  Widget _buildHome() {
    return _notes.isEmpty
        ? const Center(child: Text("Belum ada catatan."))
        : ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (_, i) {
              final n = _notes[i];
              return NoteCard(
                note: n,
                onTap: () => _showDetail(n),
                onDelete: () => _delete(n),
              );
            },
          );
  }

  // 🔹 Pop-up detail catatan
  void _showDetail(JournalNote note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.imagePath != null && note.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.file(File(note.imagePath!), fit: BoxFit.cover),
                ),
              Text(note.content),
              const SizedBox(height: 8),
              Text(
                "📅 ${note.dateTime.day}-${note.dateTime.month}-${note.dateTime.year}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editNoteDialog(note);
              },
              child: const Text("Edit")),
        ],
      ),
    );
  }

  // 🔹 Dialog edit (judul, isi, dan gambar)
  void _editNoteDialog(JournalNote note) {
    final titleC = TextEditingController(text: note.title);
    final contentC = TextEditingController(text: note.content);
    String? newImagePath = note.imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Catatan"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleC,
                      decoration: const InputDecoration(labelText: "Judul"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentC,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: "Isi Catatan"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setStateDialog(() {
                            newImagePath = picked.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Ganti Gambar"),
                    ),
                    const SizedBox(height: 10),
                    if (newImagePath != null && newImagePath!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(newImagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () async {
                    // 🔹 update data baru
                    final updatedNote = JournalNote(
                      id: note.id,
                      title: titleC.text,
                      content: contentC.text,
                      dateTime: DateTime.now(),
                      imagePath: newImagePath,
                    );

                    final index = _notes.indexWhere((n) => n.id == note.id);
                    if (index != -1) {
                      _notes[index] = updatedNote;
                      await StorageHelper.saveNotes(_notes);
                      setState(() {});
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Catatan berhasil diperbarui"),
                      ),
                    );
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> get _pages => [
        _buildHome(),
        AddPage(onSaved: _onAddNote),
        GalleryPage(notes: _notes),
      ];

  void _onAddNote(JournalNote note) async {
    _notes.insert(0, note);
    await StorageHelper.saveNotes(_notes);
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Journal")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Tambah"),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_library), label: "Galeri"),
        ],
      ),
    );
  }
}
