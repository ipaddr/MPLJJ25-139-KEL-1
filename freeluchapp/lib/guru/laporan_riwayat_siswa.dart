import 'package:flutter/material.dart';
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru

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
        // Hapus actions di sini
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16),
        //     child: Icon(Icons.account_circle, color: Colors.black),
        //   ),
        // ],
      ),

      // Sidebar Drawer
      drawer: const AppDrawerGuru(), // Menggunakan AppDrawerGuru

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
}
