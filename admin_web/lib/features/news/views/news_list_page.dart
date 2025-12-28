import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Berita'),
        actions: [
          IconButton(
            onPressed: () => context.go('/news/add'),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Berita',
          ),
        ],
      ),
      body: StreamBuilder<List<NewsModel>>(
        stream: NewsService().getNewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada berita yang dirilis.'));
          }

          final newsList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: news.imageUrl.isNotEmpty
                      ? ClipRRect( // Display image if available
                          borderRadius: BorderRadius.circular(4),
                          child: news.imageUrl.startsWith('http') 
                              ? Image.network(news.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                              : const Icon(Icons.image, size: 50),
                        )
                      : const Icon(Icons.newspaper, size: 50),
                  title: Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${news.formattedDate}\n${news.content}", 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, news),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/news/add'), 
        label: const Text('Tambah Berita'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NewsModel news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: Text('Apakah Anda yakin ingin menghapus "${news.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await NewsService().deleteNews(news.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
