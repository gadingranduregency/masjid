import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/kegiatan_page.dart';
import 'pages/aktivitas_page.dart';
import 'pages/kas_page.dart';
import 'pages/ikhtisar_page.dart';
import 'widgets/fab_menu.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SabilulAmanahApp());
}

class SabilulAmanahApp extends StatelessWidget {
  const SabilulAmanahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SABILUL AMANAH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF064E3B),
          primary: const Color(0xFF064E3B),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0; // 0=Kegiatan (main), 1=Aktivitas, 2=Kas, 3=Ikhtisar
  final ApiService _api = ApiService();
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  final List<String> titles = [
    'Kegiatan',
    'Aktivitas Masjid',
    'Kas',
    'Ikhtisar',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await _api.fetchDashboard();
      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      KegiatanPage(data: dashboardData, isLoading: isLoading, onRefresh: _loadData),
      AktivitasPage(data: dashboardData, isLoading: isLoading),
      KasPage(data: dashboardData, isLoading: isLoading),
      IkhtisarPage(data: dashboardData, isLoading: isLoading),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF10B981)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mosque, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SABILUL AMANAH',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                    Text('سبيل الأمانة • Public WebView • Read-Only',
                        style: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 20),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // FAB fixed viewport kanan bawah layar HP
      floatingActionButton: FabMenu(
        currentIndex: _currentIndex,
        onSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
