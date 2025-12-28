import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../viewmodels/complaint_list_viewmodel.dart';
import '../../../models/complaint_model.dart';
import 'complaint_detail_dialog.dart';

class ComplaintListPage extends StatelessWidget {
  const ComplaintListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComplaintListViewModel(),
      child: const _ComplaintListView(),
    );
  }
}

class _ComplaintListView extends StatelessWidget {
  const _ComplaintListView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ComplaintListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengaduan'),
        actions: [
          PopupMenuButton<ComplaintStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
            onSelected: viewModel.setFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Semua Status')),
              ...ComplaintStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: viewModel.complaintsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data ?? [];

          if (complaints.isEmpty) {
            return const Center(child: Text('Belum ada pengaduan'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final item = complaints[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: item.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        )
                      : const Icon(Icons.report_problem, color: Colors.orange),
                  title: Text(
                    item.kategori.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.fullname} • ${DateFormat('dd MMM yyyy').format(item.timestamp)}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(item.statusText),
                    backgroundColor: _getStatusColor(item.status),
                  ),
                  onTap: () async {
                    final newStatus = await showDialog<ComplaintStatus>(
                      context: context,
                      builder: (ctx) => ComplaintDetailDialog(complaint: item),
                    );

                    if (newStatus != null && context.mounted) {
                      await viewModel.updateStatus(item, newStatus);
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

  static String _statusLabel(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'MENUNGGU';
      case ComplaintStatus.processed:
        return 'DIPROSES';
      case ComplaintStatus.done:
        return 'SELESAI';
      case ComplaintStatus.rejected:
        return 'DITOLAK';
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Colors.orange.shade100;
      case ComplaintStatus.processed:
        return Colors.blue.shade100;
      case ComplaintStatus.done:
        return Colors.green.shade100;
      case ComplaintStatus.rejected:
        return Colors.red.shade100;
    }
  }
}
