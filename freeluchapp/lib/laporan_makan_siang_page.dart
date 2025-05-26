import 'package:flutter/material.dart';
import 'app_drawer.dart';

class MealReport {
  MealReport({
    required this.date,
    required this.school,
    required this.menu,
    this.status = 'Dikonfirmasi',
  });

  DateTime date;
  String school;
  String menu;
  String status;
}

class LaporanMakanSiangPage extends StatefulWidget {
  const LaporanMakanSiangPage({super.key});

  @override
  State<LaporanMakanSiangPage> createState() => _LaporanMakanSiangPageState();
}

class _LaporanMakanSiangPageState extends State<LaporanMakanSiangPage> {
  final List<MealReport> _reports = [
    MealReport(
      date: DateTime(2025, 4, 18),
      school: 'SD Negeri 1',
      menu: 'Nasi Putih, Telur Balado',
    ),
    MealReport(
      date: DateTime(2025, 4, 19),
      school: 'SD Negeri 1',
      menu: 'Sayur Lodeh, Tempe',
    ),
    MealReport(
      date: DateTime(2025, 4, 20),
      school: 'SD Negeri 1',
      menu: 'Soto Ayam, Tahu',
    ),
    MealReport(
      date: DateTime(2025, 4, 21),
      school: 'SD Negeri 1',
      menu: 'Makan Siang',
    ),
    MealReport(
      date: DateTime(2025, 4, 22),
      school: 'SD Negeri 1',
      menu: 'Makan Siang',
    ),
  ];

  final List<String> _schools = ['SD Negeri 1', 'SD Negeri 2', 'SD Negeri 3'];
  String? _selectedSchool;

  Iterable<MealReport> get _filteredReports =>
      _selectedSchool == null
          ? _reports
          : _reports.where((r) => r.school == _selectedSchool);

  void _onMenuAction(String action, MealReport report) async {
    switch (action) {
      case 'edit':
        _openMealDialog(initial: report);
        break;
      case 'add':
        _openMealDialog();
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Hapus Menu'),
                content: const Text('Yakin ingin menghapus menu ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
        );
        if (confirmed ?? false) {
          setState(() => _reports.remove(report));
        }
        break;
    }
  }

  Future<void> _openMealDialog({MealReport? initial}) async {
    final formKey = GlobalKey<FormState>();
    DateTime date = initial?.date ?? DateTime.now();
    final menuController = TextEditingController(text: initial?.menu);
    String school = initial?.school ?? (_selectedSchool ?? _schools.first);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1D3354),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: menuController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Menu',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Isi menu' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: school,
                    items:
                        _schools
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => school = v!,
                    dropdownColor: const Color(0xFF1D3354),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Sekolah',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tanggal: ${date.day}-${date.month}-${date.year}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDate: date,
                          );
                          if (picked != null) setState(() => date = picked);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          if (initial == null) {
                            _reports.add(
                              MealReport(
                                date: date,
                                school: school,
                                menu: menuController.text,
                              ),
                            );
                          } else {
                            initial
                              ..date = date
                              ..school = school
                              ..menu = menuController.text;
                          }
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(initial == null ? 'Tambah' : 'Simpan'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Laporan Makan Siang',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFCCE0F5),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFF1D3354),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: const Text(
                      'Pilih Sekolah',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _selectedSchool,
                    items:
                        _schools
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedSchool = val),
                    dropdownColor: const Color(0xFF1D3354),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFF27496D),
                  ),
                  dataRowColor: MaterialStateProperty.all(
                    const Color(0xFF1D3354),
                  ),
                  border: TableBorder.all(color: Colors.white),
                  columnSpacing: 12,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Tanggal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Sekolah',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Menu',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Aksi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  rows:
                      _filteredReports.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${r.date.day}-${r.date.month}-${r.date.year}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                r.school,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                r.menu,
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
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  r.status,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(
                              PopupMenuButton<String>(
                                color: const Color(0xFF1D3354),
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                onSelected: (value) => _onMenuAction(value, r),
                                itemBuilder:
                                    (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'add',
                                        child: Text(
                                          'Tambah Menu',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Hapus Menu',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openMealDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
