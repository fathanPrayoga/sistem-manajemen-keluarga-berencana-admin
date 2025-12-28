import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle timestamp
    Timestamp? ts = data['created_at'];
    DateTime date = ts != null ? ts.toDate() : DateTime.now();

    return NewsModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['image_url'] ?? '',
      createdAt: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
  
  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);
}
