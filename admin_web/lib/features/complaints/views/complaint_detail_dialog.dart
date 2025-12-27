import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/complaint_model.dart';

class ComplaintDetailDialog extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintDetailDialog({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    // Kita butuh context dari Parent yang punya Provider ComplaintListViewModel
    // atau kita pass ViewModel-nya ke sini.
    // Cara paling aman dlm Dialog adalah baca Provider dari context parent dialog,
    // tapi karena Dialog rute baru, kita perlu pass viewModel atau wrap provider lagi.
    // Opsi terbaik: Pass function callback atau viewModel.

    // Tapi karena kita pakai MultiProvider atau provider di atas route,
    // mari kita assume ViewModel bisa diakses atau kita panggil method update di UI parent.
    // UPDATED: Kita akan return value baru status dr Dialog, biar Parent yang update.
    // ATAU: Kita gunakan Consumer di dalam dialog jika Providernya accessible (biasanya tdk direct).

    // Simplest approach: Pass status update callback.
    return AlertDialog(
      title: const Text('Detail Pengaduan'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500, // Fixed width for web dialog
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Kategori', complaint.kategori),
              _buildInfoRow('Status', complaint.statusText),
              _buildInfoRow(
                'Tanggal',
                DateFormat('dd MMMM yyyy HH:mm').format(complaint.timestamp),
              ),
              const Divider(),
              _buildInfoRow('Nama Pelapor', complaint.fullname),
              _buildInfoRow('NIK', complaint.nik),
              _buildInfoRow('No. HP', complaint.phone),
              _buildInfoRow('Alamat', complaint.address),
              const Divider(),
              const Text(
                'Isi Keluhan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(complaint.description),
              if (complaint.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Bukti Foto:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    complaint.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) =>
                        const Center(child: Text('Gagal memuat gambar')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (complaint.status == ComplaintStatus.pending)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _updateStatus(context, ComplaintStatus.processed),
            child: const Text('Proses Laporan'),
          ),
        if (complaint.status == ComplaintStatus.processed) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _updateStatus(context, ComplaintStatus.rejected),
            child: const Text('Tolak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _updateStatus(context, ComplaintStatus.done),
            child: const Text('Selesai'),
          ),
        ],
      ],
    );
  }

  void _updateStatus(BuildContext context, ComplaintStatus newStatus) {
    // Return the newStatus to the caller
    Navigator.pop(context, newStatus);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
