import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/complaint_list_viewmodel.dart';
import 'package:intl/intl.dart';
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
          // Dropdown Filter
          PopupMenuButton<ComplaintStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
            onSelected: viewModel.setFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Semua Status')),
              ...ComplaintStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last.toUpperCase()),
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

          var complaints = snapshot.data ?? [];

          // Client-side filtering
          if (viewModel.filterStatus != null) {
            complaints = complaints
                .where((c) => c.status == viewModel.filterStatus)
                .toList();
          }

          if (complaints.isEmpty) {
            return const Center(child: Text('Belum ada pengaduan'));
          }

          // Gunakan ListView card agar responsif vs DataTable yang bisa overflow
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final item = complaints[index];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.report_problem,
                    color: Colors.orange,
                  ),
                  title: Text(
                    item.kategori,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.fullname} - ${DateFormat('dd MMM yyyy').format(item.timestamp)}',
                      ),
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
                      viewModel.updateStatus(item.id, newStatus);
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
