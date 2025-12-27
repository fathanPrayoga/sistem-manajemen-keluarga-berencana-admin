import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/kb_list_viewmodel.dart';
import '../../../models/kb_model.dart';

class KbListPage extends StatelessWidget {
  const KbListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KbListViewModel(),
      child: const _KbListView(),
    );
  }
}

class _KbListView extends StatelessWidget {
  const _KbListView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KbListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran KB'),
        actions: [
          PopupMenuButton<KbStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
            onSelected: viewModel.setFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Semua Status')),
              ...KbStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<KbRegistrationModel>>(
        stream: viewModel.registrationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var items = snapshot.data ?? [];

          if (viewModel.filterStatus != null) {
            items = items
                .where((i) => i.status == viewModel.filterStatus)
                .toList();
          }

          if (items.isEmpty) {
            return const Center(child: Text('Belum ada pendaftaran'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.family_restroom,
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    item.fullname,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.serviceTypeText} • ${DateFormat('dd MMM yyyy').format(item.bookingDate)}',
                  ),
                  trailing: Chip(
                    label: Text(
                      item.statusText,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(item.status),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('NIK', item.nik),
                          _buildInfoRow('No. HP', item.phone),
                          _buildInfoRow('Alamat', item.alamat),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (item.status == KbStatus.pending)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text('Konfirmasi Kedatangan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => viewModel.updateStatus(
                                    item.id,
                                    KbStatus.confirmed,
                                  ),
                                ),
                              if (item.status == KbStatus.confirmed) ...[
                                OutlinedButton(
                                  child: const Text('Batal'),
                                  onPressed: () => viewModel.updateStatus(
                                    item.id,
                                    KbStatus.rejected,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Selesai Pelayanan'),
                                  onPressed: () => viewModel.updateStatus(
                                    item.id,
                                    KbStatus.done,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(KbStatus status) {
    switch (status) {
      case KbStatus.pending:
        return Colors.orange.shade100;
      case KbStatus.confirmed:
        return Colors.blue.shade100;
      case KbStatus.done:
        return Colors.green.shade100;
      case KbStatus.rejected:
        return Colors.red.shade100;
    }
  }
}
