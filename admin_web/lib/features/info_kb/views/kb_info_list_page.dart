import 'package:flutter/material.dart';

class KbInfoListPage extends StatelessWidget {
  const KbInfoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Info KB')),
      body: const Center(child: Text('Info KB Management Content')),
    );
  }
}
