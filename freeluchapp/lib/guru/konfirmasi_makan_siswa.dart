import 'package:flutter/material.dart';
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru

class KonfirmasiMakanSiswa extends StatefulWidget {
  const KonfirmasiMakanSiswa({super.key});

  @override
  State<KonfirmasiMakanSiswa> createState() => _KonfirmasiMakanSiswaState();
}

class _KonfirmasiMakanSiswaState extends State<KonfirmasiMakanSiswa> {
  List<Map<String, String>> siswa = [
    {'nama': 'Budi Santoso', 'status': 'Dikonfirmasi'},
    {'nama': 'Dewi Lestari', 'status': 'Belum Dikonfirmasi'},
    {'nama': 'Rina Wijaya', 'status': 'Dikonfirmasi'},
    {'nama': 'Siti Aminah', 'status': 'Belum Dikonfirmasi'},
    {'nama': 'Ahmad Fauzi', 'status': 'Dikonfirmasi'},
    {'nama': 'Lisa Permata', 'status': 'Belum Dikonfirmasi'},
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
          // Tambahkan Builder untuk icon menu drawer
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        // Hapus actions di sini
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 12.0),
        //     child: Icon(
        //       Icons.account_circle,
        //       color: Colors.black,
        //     ),
        //   ),
        // ],
      ),

      drawer: const AppDrawerGuru(), // Tambahkan drawer di sini
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blueGrey.shade800,
                    ),
                    headingTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows:
                        filteredSiswa.map((s) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  s['nama']!,
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
                                    color:
                                        s['status'] == 'Dikonfirmasi'
                                            ? Colors.green.shade300
                                            : Colors.orange.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    s['status']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      s['status'] =
                                          s['status'] == 'Dikonfirmasi'
                                              ? 'Belum Dikonfirmasi'
                                              : 'Dikonfirmasi';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        s['status'] == 'Dikonfirmasi'
                                            ? Colors.red.shade400
                                            : Colors.green.shade400,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    s['status'] == 'Dikonfirmasi'
                                        ? 'Batalkan'
                                        : 'Konfirmasi',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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
