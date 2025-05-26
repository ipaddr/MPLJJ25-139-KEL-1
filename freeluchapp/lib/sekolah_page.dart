import 'package:flutter/material.dart';
import 'sekolah_form_page.dart';
import 'app_drawer.dart';

class SekolahPage extends StatefulWidget {
  const SekolahPage({super.key});

  @override
  State<SekolahPage> createState() => _SekolahPageState();
}

class _SekolahPageState extends State<SekolahPage> {
  List<Map<String, String>> sekolahList = [
    {'nama': 'SD Negeri 1', 'alamat': 'Jl.Sudirman No.1'},
    {'nama': 'SD Negeri 2', 'alamat': 'Jl.Hasanuddin No.5'},
    {'nama': 'SD Negeri 3', 'alamat': 'Jl.Diponegoro No.12'},
    {'nama': 'SD Negeri 4', 'alamat': 'Jl.RA Kartini No.7'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ganti Drawer lama dengan ini
      appBar: AppBar(
        title: const Text("Sekolah"),
        backgroundColor: const Color(0xFFCCE0F5),
      ),
      backgroundColor: const Color(0xFF1D3354),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SekolahFormPage()),
                  );
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      sekolahList.add(result);
                    });
                  }
                },
                child: const Text("Tambah"),
              ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.white),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFF27496D)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Nama",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Alamat",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Aksi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < sekolahList.length; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          sekolahList[i]['nama']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          sekolahList[i]['alamat']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                minimumSize: const Size(60, 36),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => SekolahFormPage(
                                          nama: sekolahList[i]['nama'],
                                          alamat: sekolahList[i]['alamat'],
                                        ),
                                  ),
                                );
                                if (result != null &&
                                    result is Map<String, String>) {
                                  setState(() {
                                    sekolahList[i] = result;
                                  });
                                }
                              },
                              child: const Text(
                                "Edit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                minimumSize: const Size(60, 36),
                              ),
                              onPressed: () async {
                                final konfirmasi = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: Text(
                                          'Hapus sekolah "${sekolahList[i]['nama']}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                );
                                if (konfirmasi == true) {
                                  setState(() {
                                    sekolahList.removeAt(i);
                                  });
                                }
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
