import 'package:flutter/material.dart';
import 'app_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDEEFF),
        elevation: 2,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: const Color(0xFF1F355D),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCard(Icons.school, "Total Sekolah"),
                _infoCard(Icons.calendar_today, "Total Jadwal Makan"),
                _infoCard(Icons.check_circle, "Total Terkonfirmasi"),
                _infoCard(Icons.cancel, "Jadwal Belum Konfirmasi"),
              ],
            ),
            const SizedBox(height: 24),
            _chartSection(),
            const SizedBox(height: 24),
            _jadwalTerbaruSection(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label) {
    return Card(
      color: const Color(0xFF1F355D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white),
      ),
      child: SizedBox(
        width: 70,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C4A7A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                "Jadwal Makan Per Sekolah",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text("Filter", style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            color: Colors.white,
            child: const Center(
              child: Text("Grafik", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jadwalTerbaruSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C4A7A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Jadwal Terbaru",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _jadwalRow(
            "16 Oct 2025",
            "SDN 01 Indah",
            "Ayam Goreng",
            "Dikonfirmasi",
          ),
          _jadwalRow(
            "17 Oct 2025",
            "SDN 02 Permata",
            "Dendeng",
            "Belum Konfirmasi",
          ),
          _jadwalRow(
            "18 Oct 2025",
            "SDN 03 Biru",
            "Rendang",
            "Belum Konfirmasi",
          ),
          _jadwalRow(
            "19 Oct 2025",
            "SDN 04 Putih",
            "Gurame Bakar",
            "Konfirmasi",
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Lihat Semua >",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jadwalRow(
    String tanggal,
    String sekolah,
    String menu,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              tanggal,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              sekolah,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              menu,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                color:
                    status.toLowerCase().contains("belum")
                        ? Colors.red
                        : Colors.greenAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
