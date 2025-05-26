import 'package:flutter/material.dart';
import 'app_drawer.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // Gunakan komponen drawer yang benar
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDEEFF),
        elevation: 2,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text('Statistik', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        color: const Color(0xFF1F355D),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatBox(),
            const SizedBox(height: 16),
            _buildPieChartCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(title: 'Total Jadwal Makan', value: '120'),
          _StatItem(title: 'Terkonfirmasi', value: '110'),
          _StatItem(title: 'Belum Konfirmasi', value: '10'),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jadwal Makan per Sekolah',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // Gambar pie chart (placeholder)
                  Expanded(
                    child: Image.asset(
                      'assets/statistik_chart.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _LegendItem(color: Colors.blue, label: 'SD Negeri 1'),
                      _LegendItem(color: Colors.green, label: 'SD Negeri 2'),
                      _LegendItem(color: Colors.amber, label: 'SD Negeri 3'),
                      _LegendItem(color: Colors.red, label: 'SD Negeri 4'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
