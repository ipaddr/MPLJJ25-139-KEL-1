import 'package:flutter/material.dart';
import 'package:freeluchapp/app_drawer.dart';
// import 'package:fl_chart/fl_chart.dart'; // Tambahkan ini jika Anda akan menggunakan grafik sungguhan

// Hapus import 'sekolah_page.dart'; karena tidak langsung digunakan di sini.
// import 'sekolah_page.dart'; // <<<--- HAPUS BARIS INI

// Import halaman lain yang akan dihubungkan dari "Lihat Semua"
import 'laporan_makan_siang_page.dart'; // Pastikan sudah ada

// Mengubah dari StatelessWidget menjadi StatefulWidget untuk mengelola data dinamis
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Variabel untuk menyimpan data dashboard
  int totalSekolah = 0;
  int totalJadwalMakan = 0;
  int totalTerkonfirmasi = 0;
  int jadwalBelumKonfirmasi = 0;
  List<Map<String, String>> jadwalTerbaru = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Panggil fungsi untuk mengambil data saat initState
  }

  // Fungsi async untuk mengambil data dashboard
  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // --- SIMULASI PENGAMBILAN DATA (GANTI DENGAN LOGIKA ASLI DARI FIREBASE/API) ---
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulasikan loading data

      // Contoh data dummy (ganti dengan data dari Firestore/Realtime Database)
      totalSekolah = 15;
      totalJadwalMakan = 120;
      totalTerkonfirmasi = 95;
      jadwalBelumKonfirmasi = 25;
      jadwalTerbaru = [
        {
          "tanggal": "16 Okt 2025",
          "sekolah": "SDN 01 Indah",
          "menu": "Ayam Goreng",
          "status": "Dikonfirmasi",
        },
        {
          "tanggal": "17 Okt 2025",
          "sekolah": "SDN 02 Permata",
          "menu": "Dendeng",
          "status": "Belum Konfirmasi",
        },
        {
          "tanggal": "18 Okt 2025",
          "sekolah": "SDN 03 Biru",
          "menu": "Rendang",
          "status": "Belum Konfirmasi",
        },
        {
          "tanggal": "19 Okt 2025",
          "sekolah": "SDN 04 Putih",
          "menu": "Gurame Bakar",
          "status": "Dikonfirmasi",
        },
        {
          "tanggal": "20 Okt 2025",
          "sekolah": "SMP 01 Jaya",
          "menu": "Sate",
          "status": "Belum Konfirmasi",
        },
      ];
      // --------------------------------------------------------------------------

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data: ${e.toString()}';
        });
      }
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchDashboardData, // Tombol refresh data
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F355D),
      drawer: const AppDrawer(),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Section Info Cards
                    _buildInfoCardsSection(),
                    const SizedBox(height: 24),

                    // Section Chart
                    _chartSection(),
                    const SizedBox(height: 24),

                    // Section Jadwal Terbaru
                    _jadwalTerbaruSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCardsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoCard(Icons.school, "Total Sekolah", totalSekolah),
        _infoCard(Icons.calendar_today, "Total Jadwal Makan", totalJadwalMakan),
        _infoCard(Icons.check_circle, "Terkonfirmasi", totalTerkonfirmasi),
        _infoCard(Icons.cancel, "Belum Konfirmasi", jadwalBelumKonfirmasi),
      ],
    );
  }

  Widget _infoCard(IconData icon, String label, int value) {
    return Card(
      color: const Color(0xFF2C4A7A), // Warna sedikit berbeda agar menonjol
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Colors.white24,
          width: 0.5,
        ), // Border lebih halus
      ),
      child: Container(
        // Menggunakan Container dengan padding untuk kontrol ukuran
        width:
            MediaQuery.of(context).size.width / 4 -
            24, // Disesuaikan agar responsif
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ), // Ukuran icon lebih besar
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ), // Warna teks lebih lembut
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(), // Menampilkan nilai dinamis
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ), // Ukuran dan gaya nilai
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
        border: Border.all(color: Colors.white24, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16), // Padding lebih besar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Jadwal Makan Per Sekolah",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Tombol Filter (bisa jadi DropdownButton atau IconButton dengan dialog)
              InkWell(
                onTap: () {
                  // TODO: Implementasi logika filter chart
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter Chart Belum Diimplementasi'),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      "Filter",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.filter_list, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Placeholder untuk grafik sungguhan
          Container(
            height: 200, // Tinggi yang lebih realistis untuk grafik
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              // Menghilangkan 'const' di sini agar bisa lebih dinamis jika nanti ada grafik
              child: Text(
                // Jika Anda menggunakan fl_chart atau library grafik lain, render di sini
                "Placeholder Grafik (Misal: BarChart, PieChart)",
                style: TextStyle(color: Colors.black54),
              ),
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
        border: Border.all(color: Colors.white24, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16), // Padding lebih besar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Jadwal Terbaru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Navigasi ke halaman Laporan Makan Siswa
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LaporanMakanSiangPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Lihat Semua >",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          // Memastikan ada padding di bawah judul sebelum daftar jadwal
          const SizedBox(height: 8),
          // Gunakan ListView.builder jika data jadwal banyak untuk performa
          if (jadwalTerbaru.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Tidak ada jadwal terbaru.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            // Hapus .toList() di sini
            ...jadwalTerbaru.map((jadwal) {
              return _jadwalRow(
                jadwal["tanggal"]!,
                jadwal["sekolah"]!,
                jadwal["menu"]!,
                jadwal["status"]!,
              );
            }), // <<<--- UBAH DI SINI: Hapus .toList()
          const SizedBox(height: 8), // Padding di bawah daftar jadwal
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Padding lebih besar
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              tanggal,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              sekolah,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              menu,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                color:
                    status.toLowerCase().contains("belum")
                        ? Colors.redAccent
                        : Colors.greenAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold, // Status lebih menonjol
              ),
            ),
          ),
        ],
      ),
    );
  }
}
