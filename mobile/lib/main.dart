import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';
import 'widgets/neon_navbar.dart';
import 'widgets/booking_sheet.dart';
import 'widgets/auth_modal.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using user's real project credentials
  try {
    await Supabase.initialize(
      url: 'https://cmtvzjcjinivkquhheqo.supabase.co',
      anonKey: 'sb_publishable_xCwyI9klXX30unaDht3TPw_KidrW5o2',
    );
  } catch (e) {
    debugPrint('Supabase init warning: $e');
  }

  runApp(const LpkIndotechApp());
}

class LpkIndotechApp extends StatelessWidget {
  const LpkIndotechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LPK INDOTECH Driving Partner',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  String _searchQuery = '';
  bool _showSearchPopup = false;
  final TextEditingController _searchController = TextEditingController();

  void _openBookingSheet(Instructor instructor, [DrivingPackage? pkg]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        instructor: instructor,
        selectedPackage: pkg,
      ),
    );
  }

  void _openAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glow Background Circles (Glassy Atmosphere)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.08),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      HomeScreen(
                        onBookInstructor: (inst, pkg) => _openBookingSheet(inst, pkg),
                        onNavigateToSearch: () => setState(() => _currentIndex = 1),
                        onNavigateToSchedule: () => setState(() => _currentIndex = 2),
                        onNavigateToProgress: () => setState(() => _currentIndex = 3),
                      ),
                      SearchScreen(
                        onBookInstructor: (inst) => _openBookingSheet(inst),
                        searchQuery: _searchQuery,
                      ),
                      ScheduleScreen(
                        onBookMore: () => setState(() => _currentIndex = 1),
                      ),
                      const ProgressScreen(),
                      ProfileScreen(
                        onOpenAuth: _openAuthModal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Search Pill (Directly from Video V5 Frame 04)
          if (_showSearchPopup && _currentIndex == 1)
            Positioned(
              bottom: 96,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xF018181C),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Cari instruktur, lokasi Purwokerto...',
                          hintStyle: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),

          // Floating Glassy Neon Arch Navbar (Video V5)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NeonArchNavbar(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() {
                  _currentIndex = index;
                  if (index != 1) _showSearchPopup = false;
                });
              },
              onSearchTriggered: () {
                setState(() => _showSearchPopup = !_showSearchPopup);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10),
                  ],
                ),
                child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'LPK ',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                      children: [
                        TextSpan(text: 'INDOTECH', style: TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Purwokerto Utara', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Auth / Profile Button
          GestureDetector(
            onTap: _openAuthModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_circle_rounded, size: 16, color: AppColors.primaryLight),
                  SizedBox(width: 4),
                  Text('Akun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
