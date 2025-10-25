class JournalNote {
  String id;
  String title;
  String content;
  DateTime dateTime;
  String? imagePath;

  JournalNote({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'dateTime': dateTime.toIso8601String(),
        'imagePath': imagePath,
      };

  factory JournalNote.fromJson(Map<String, dynamic> json) => JournalNote(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        dateTime: DateTime.parse(json['dateTime']),
        imagePath: json['imagePath'],
      );
}
