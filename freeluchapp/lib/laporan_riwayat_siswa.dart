import 'package:flutter/material.dart';

class LaporanRiwayatSiswa extends StatefulWidget {
  const LaporanRiwayatSiswa({Key? key}) : super(key: key);

  @override
  State<LaporanRiwayatSiswa> createState() => _LaporanRiwayatSiswaState();
}

class _LaporanRiwayatSiswaState extends State<LaporanRiwayatSiswa> {
  String selectedName = 'Dewi Lestari';

  final List<Map<String, String>> data = [
    {
      'tanggal': '22 Oct 2025',
      'jadwal': 'Makan Siang',
      'menu': 'Nasi Goreng, tahu',
      'status': 'Dikonfirmasi',
    },
    {
      'tanggal': '21 Oct 2025',
      'jadwal': 'Makan Siang',
      'menu': 'Tempe, Sayur Lodeh',
      'status': 'Dikonfirmasi',
    },
    {
      'tanggal': '20 Oct 2025',
      'jadwal': 'Makan Siang',
      'menu': 'Soto Ayam, Tahu',
      'status': 'Dikonfirmasi',
    },
    {
      'tanggal': '19 Oct 2025',
      'jadwal': 'Makan Siang',
      'menu': 'Sayur Lodeh, Tempe',
      'status': 'Dikonfirmasi',
    },
    {
      'tanggal': '18 Oct 2025',
      'jadwal': 'Makan Siang',
      'menu': 'Ikan Bakar, Lalapan',
      'status': 'Dikonfirmasi',
    },
    {
      'tanggal': '18 Oct 2025',
      'jadwal': 'Makan Siang',
      'menu': 'Nasi Putih, Telur Balado',
      'status': 'Dikonfirmasi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C355E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDBEAFF),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: const Text(
          'Laporan Riwayat Siswa',
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle, color: Colors.black),
          ),
        ],
      ),

      // Sidebar Drawer
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1C355E),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: const Color(0xFFDBEAFF),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Guru Pengguna',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'guru@email.com',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _buildSidebarItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildSidebarItem(
                icon: Icons.schedule,
                label: 'Jadwal & Menu',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildSidebarItem(
                icon: Icons.report,
                label: 'Laporan Riwayat Makan',
                isActive: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildSidebarItem(
                icon: Icons.check_circle,
                label: 'Konfirmasi Makan',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.white),
              _buildSidebarItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi logout di sini
                },
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown dan Filter
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedName,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedName = newValue!;
                          });
                        },
                        items:
                            <String>[
                              'Dewi Lestari',
                              'Budi Santoso',
                              'Siti Aminah',
                              'Rina Wijaya',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika filter
                    },
                    child: const Text("Filter"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tabel data
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.blueGrey.shade800,
                  ),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Jadwal')),
                    DataColumn(label: Text('Menu')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows:
                      data.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item['tanggal']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['jadwal']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['menu']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['status']!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      color: isActive ? Colors.white24 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
      ),
    );
  }
}
