import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, size: 28, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _statCard(Icons.school, 'Total Sekolah'),
                _statCard(Icons.calendar_today, 'Total Jadwal Makan'),
                _statCard(Icons.mail, 'Total Konfirmasi'),
                _statCard(Icons.done_all, 'Jadwal Telah Dikonfirmasi'),
              ],
            ),
            const SizedBox(height: 20),
            _chartSection(),
            const SizedBox(height: 20),
            _tableSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE3F2FD),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Log out'),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String title) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1D3557),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _chartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3557),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Jadwal Makan Per Sekolah',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text('Filter', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            color: Colors.white,
            child: const Center(child: Text('Grafik Placeholder')),
          ),
        ],
      ),
    );
  }

  Widget _tableSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1D3557),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Jadwal Terbaru',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataTable(
            columnSpacing: 10,
            columns: const [
              DataColumn(
                label: Text('Tanggal', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Sekolah', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Menu', style: TextStyle(color: Colors.white)),
              ),
              DataColumn(
                label: Text('Status', style: TextStyle(color: Colors.white)),
              ),
            ],
            rows: [
              _dataRow(
                '16 Oct 2025',
                'SDN 01 Indah',
                'Ayam Goreng',
                'Dikonfirmasi',
              ),
              _dataRow(
                '17 Oct 2025',
                'SDN 02 Permata',
                'Dendeng',
                'Belum Konfirmasi',
              ),
              _dataRow(
                '18 Oct 2025',
                'SDN 03 Biru',
                'Rendang',
                'Belum Konfirmasi',
              ),
              _dataRow(
                '19 Oct 2025',
                'SDN 04 Putih',
                'Gurame Bakar',
                'Konfirmasi',
              ),
            ],
            dataRowColor: MaterialStateProperty.resolveWith(
              (_) => Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8, right: 8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text('Lihat Semua', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _dataRow(String tgl, String sekolah, String menu, String status) {
    return DataRow(
      cells: [
        DataCell(Text(tgl, style: const TextStyle(fontSize: 10))),
        DataCell(Text(sekolah, style: const TextStyle(fontSize: 10))),
        DataCell(Text(menu, style: const TextStyle(fontSize: 10))),
        DataCell(Text(status, style: const TextStyle(fontSize: 10))),
      ],
    );
  }
}
