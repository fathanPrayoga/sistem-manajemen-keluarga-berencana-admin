import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'news';

  // Get Stream of News
  Stream<List<NewsModel>> getNewsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NewsModel.fromFirestore(doc)).toList();
    });
  }

  // Add News
  Future<void> addNews(NewsModel news) async {
    await _firestore.collection(_collection).add(news.toMap());
  }

  // Delete News
  Future<void> deleteNews(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
