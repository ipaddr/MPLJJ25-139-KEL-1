import 'package:flutter/material.dart';

class KonfirmasiMakanSiswa extends StatefulWidget {
  const KonfirmasiMakanSiswa({super.key});

  @override
  State<KonfirmasiMakanSiswa> createState() => _KonfirmasiMakanSiswaState();
}

class _KonfirmasiMakanSiswaState extends State<KonfirmasiMakanSiswa> {
  List<Map<String, String>> siswa = [
    {'nama': 'Budi Santoso', 'status': 'Dikonfirmasi'},
    {'nama': 'Dewi Lestari', 'status': 'Dikonfirmasi'},
    {'nama': 'Rina Wijaya', 'status': 'Dikonfirmasi'},
    {'nama': 'Siti Aminah', 'status': 'Dikonfirmasi'},
  ];

  List<Map<String, String>> filteredSiswa = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSiswa = List.from(siswa);
  }

  void _filterSiswa(String query) {
    setState(() {
      filteredSiswa =
          siswa
              .where(
                (s) => s['nama']!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F365D),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCE6FF),
        title: const Text(
          'Konfirmasi Makan Siswa',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.account_circle, color: Colors.black),
          ),
        ],
      ),

      // Drawer Sidebar
      drawer: Drawer(
        width: 250,
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: const Color(0xFFCCE6FF),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFE9D8FD),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ibu Adelya',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Online',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
              ),
              const ListTile(
                leading: Icon(Icons.restaurant_menu),
                title: Text('Jadwal & Menu'),
              ),
              const ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('Laporan Riwayat Makan'),
              ),
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text('Konfirmasi Makan'),
              ),
              const ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Kolom pencarian
            TextField(
              controller: searchController,
              onChanged: _filterSiswa,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Cari Siswa',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabel
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.symmetric(
                      inside: const BorderSide(color: Colors.white),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                    },
                    children: [
                      // Header
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.transparent),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Nama',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Data siswa
                      ...filteredSiswa.map((s) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                s['nama']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Bisa tambahkan logika jika ingin mengubah status
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(
                                  s['status']!,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
