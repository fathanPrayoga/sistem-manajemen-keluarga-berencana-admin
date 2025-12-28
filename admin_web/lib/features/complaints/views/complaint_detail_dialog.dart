import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/complaint_model.dart';

class ComplaintDetailDialog extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintDetailDialog({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detail Pengaduan'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520, // nyaman untuk web
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionTitle('Informasi Pengaduan'),
              _buildInfoRow('Kategori', complaint.kategori.toUpperCase()),
              _buildInfoRow('Status', complaint.statusText),
              _buildInfoRow(
                'Tanggal',
                DateFormat('dd MMMM yyyy HH:mm').format(complaint.timestamp),
              ),

              const Divider(height: 24),

              _buildSectionTitle('Data Pelapor'),
              _buildInfoRow('Nama', complaint.fullname),
              _buildInfoRow('NIK', complaint.nik),
              _buildInfoRow('No. HP', complaint.phone),
              _buildInfoRow('Alamat', complaint.address),

              const Divider(height: 24),

              _buildSectionTitle('Isi Keluhan'),
              Text(complaint.description),

              if (complaint.imageUrl.isNotEmpty) ...[
                const Divider(height: 24),
                _buildSectionTitle('Bukti Foto'),

                GestureDetector(
                  onTap: () {
                    _showImagePreview(context, complaint.imageUrl);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      complaint.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 220,
                        child: Center(child: Text('Gagal memuat gambar')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ketuk gambar untuk memperbesar',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Tutup'),
      ),
    ];

    if (complaint.status == ComplaintStatus.pending) {
      actions.add(
        ElevatedButton(
          onPressed: () => _returnStatus(context, ComplaintStatus.processed),
          child: const Text('Proses'),
        ),
      );
    }

    if (complaint.status == ComplaintStatus.processed) {
      actions.addAll([
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _returnStatus(context, ComplaintStatus.rejected),
          child: const Text('Tolak'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => _returnStatus(context, ComplaintStatus.done),
          child: const Text('Selesai'),
        ),
      ]);
    }

    return actions;
  }

  void _returnStatus(BuildContext context, ComplaintStatus status) {
    Navigator.pop(context, status);
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(child: Image.network(imageUrl)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
