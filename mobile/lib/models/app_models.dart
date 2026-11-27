import 'package:flutter/foundation.dart';

enum UserRole { siswa, mitra, admin }

enum AppFlavor { user, mitra, console, portal }

class LpkBranch {
  final String id;
  final String name;
  final String city;
  final String licenseNumber;
  final String ownerName;
  final String ownerPhone;
  final int activeDrivers;
  final int activeStudents;
  final int monthlyOmzet;
  final String status; // pending, verified, suspended

  const LpkBranch({
    required this.id,
    required this.name,
    required this.city,
    required this.licenseNumber,
    required this.ownerName,
    required this.ownerPhone,
    required this.activeDrivers,
    required this.activeStudents,
    required this.monthlyOmzet,
    required this.status,
  });

  LpkBranch copyWith({String? status}) {
    return LpkBranch(
      id: id,
      name: name,
      city: city,
      licenseNumber: licenseNumber,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      activeDrivers: activeDrivers,
      activeStudents: activeStudents,
      monthlyOmzet: monthlyOmzet,
      status: status ?? this.status,
    );
  }
}

enum TripStage {
  pending,      // Menunggu respon mitra
  accepted,     // Diterima & terjadwal
  onTheWay,     // Mitra menuju lokasi siswa
  arrived,      // Tiba di lokasi siswa
  training,     // Sedang latihan
  completed,    // Selesai & siap dinilai
  rejected,     // Dialihkan
}

class Instructor {
  final String id;
  final String name;
  final String initial;
  final String originDriver; // e.g., "Eks Driver GoCar • 7 thn"
  final String carModel;
  final String plateNumber;
  final double rating;
  final int reviews;
  final double distanceKm;
  final int etaMinutes;
  final List<String> transmissions;
  final int experienceYears;
  final int sessionsCompleted;
  final String area;
  final bool isOnline;
  final bool dualBrakeVerified;
  final double mapX; // 0.1..0.9 for radar map
  final double mapY; // 0.1..0.9 for radar map

  const Instructor({
    required this.id,
    required this.name,
    required this.initial,
    required this.originDriver,
    required this.carModel,
    required this.plateNumber,
    required this.rating,
    required this.reviews,
    required this.distanceKm,
    required this.etaMinutes,
    required this.transmissions,
    required this.experienceYears,
    required this.sessionsCompleted,
    required this.area,
    required this.isOnline,
    this.dualBrakeVerified = true,
    required this.mapX,
    required this.mapY,
  });
}

class DrivingPackage {
  final String id;
  final String name;
  final String description;
  final int sessions;
  final int price;
  final List<String> features;
  final bool isPopular;

  const DrivingPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.sessions,
    required this.price,
    required this.features,
    this.isPopular = false,
  });

  DrivingPackage copyWith({int? price}) {
    return DrivingPackage(
      id: id,
      name: name,
      description: description,
      sessions: sessions,
      price: price ?? this.price,
      features: features,
      isPopular: isPopular,
    );
  }
}

class BookingOrder {
  final String id;
  final String studentName;
  final String studentPhone;
  final String pickupAddress;
  final double distanceKm;
  final String instructorId;
  final String instructorName;
  final String carInfo;
  final String transmission;
  final String packageName;
  final DateTime date;
  final String timeSlot;
  final int totalPrice;
  final int mitraEarning;
  final int sessionIndex;
  final int totalSessions;
  final TripStage stage;

  const BookingOrder({
    required this.id,
    required this.studentName,
    required this.studentPhone,
    required this.pickupAddress,
    required this.distanceKm,
    required this.instructorId,
    required this.instructorName,
    required this.carInfo,
    required this.transmission,
    required this.packageName,
    required this.date,
    required this.timeSlot,
    required this.totalPrice,
    required this.mitraEarning,
    required this.sessionIndex,
    required this.totalSessions,
    required this.stage,
  });

  BookingOrder copyWith({TripStage? stage}) {
    return BookingOrder(
      id: id,
      studentName: studentName,
      studentPhone: studentPhone,
      pickupAddress: pickupAddress,
      distanceKm: distanceKm,
      instructorId: instructorId,
      instructorName: instructorName,
      carInfo: carInfo,
      transmission: transmission,
      packageName: packageName,
      date: date,
      timeSlot: timeSlot,
      totalPrice: totalPrice,
      mitraEarning: mitraEarning,
      sessionIndex: sessionIndex,
      totalSessions: totalSessions,
      stage: stage ?? this.stage,
    );
  }
}

class CurriculumModule {
  final String id;
  final String title;
  final String subtitle;
  final bool completed;
  final int? score;
  final String? instructorNotes;

  const CurriculumModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.completed,
    this.score,
    this.instructorNotes,
  });

  CurriculumModule copyWith({
    bool? completed,
    int? score,
    String? instructorNotes,
  }) {
    return CurriculumModule(
      id: id,
      title: title,
      subtitle: subtitle,
      completed: completed ?? this.completed,
      score: score ?? this.score,
      instructorNotes: instructorNotes ?? this.instructorNotes,
    );
  }
}

class PendingMitra {
  final String id;
  final String name;
  final String phone;
  final String driverBackground;
  final String simType;
  final String carInfo;
  final String area;
  final bool ktpUploaded;
  final bool simUploaded;
  final bool stnkUploaded;
  final bool dualBrakeChecked;
  final String status; // pending, approved, revision

  const PendingMitra({
    required this.id,
    required this.name,
    required this.phone,
    required this.driverBackground,
    required this.simType,
    required this.carInfo,
    required this.area,
    this.ktpUploaded = true,
    this.simUploaded = true,
    this.stnkUploaded = true,
    this.dualBrakeChecked = true,
    this.status = 'pending',
  });

  PendingMitra copyWith({String? status}) {
    return PendingMitra(
      id: id,
      name: name,
      phone: phone,
      driverBackground: driverBackground,
      simType: simType,
      carInfo: carInfo,
      area: area,
      ktpUploaded: ktpUploaded,
      simUploaded: simUploaded,
      stnkUploaded: stnkUploaded,
      dualBrakeChecked: dualBrakeChecked,
      status: status ?? this.status,
    );
  }
}

class GraduationRecord {
  final String id;
  final String studentName;
  final String instructorName;
  final double avgScore;
  final String simStep;
  final String certNumber;
  final bool approved;

  const GraduationRecord({
    required this.id,
    required this.studentName,
    required this.instructorName,
    required this.avgScore,
    required this.simStep,
    required this.certNumber,
    required this.approved,
  });

  GraduationRecord copyWith({bool? approved}) {
    return GraduationRecord(
      id: id,
      studentName: studentName,
      instructorName: instructorName,
      avgScore: avgScore,
      simStep: simStep,
      certNumber: certNumber,
      approved: approved ?? this.approved,
    );
  }
}

class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final bool isCredit;
  final String dateLabel;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.dateLabel,
  });
}

class ServiceAreaConfig {
  final String name;
  final int activeDrivers;
  final bool active;

  const ServiceAreaConfig({
    required this.name,
    required this.activeDrivers,
    required this.active,
  });

  ServiceAreaConfig copyWith({bool? active}) {
    return ServiceAreaConfig(
      name: name,
      activeDrivers: activeDrivers,
      active: active ?? this.active,
    );
  }
}

/// Shared AppState connecting Siswa ↔ Mitra Driver ↔ Admin LPK in real-time (Clean Beta State)
class AppState extends ChangeNotifier {
  UserRole currentRole = UserRole.siswa;
  bool isLoggedIn = false;
  bool isSuperAdmin = false;
  bool isMaster = false;
  String currentUsername = '';
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String studentLocation = 'Purwokerto Utara';
  String studentAddress = '';
  String studentTransmission = 'Manual (MT)';

  // Smart Revenue Split (configurable by Admin LPK)
  int mitraSplitPercent = 60;
  int lpkSplitPercent = 27;
  int platformSplitPercent = 13;

  // Mitra Online Driver State (starts fresh for beta testing)
  bool mitraIsOnline = false;
  double mitraServiceRadius = 5.0;
  List<String> mitraServiceAreas = ['Purwokerto Utara'];
  String mitraCarInfo = 'Belum ada armada terdaftar';
  int mitraWalletBalance = 0;
  int mitraMonthlySessions = 0;

  // Instructors (populated dynamically when Mitra KYC is approved by Admin LPK)
  final List<Instructor> instructors = [];

  // Official Packages Catalog
  final List<DrivingPackage> packages = [
    const DrivingPackage(
      id: 'PKG-1',
      name: 'Paket Pemula',
      description: 'Pengenalan kendaraan, dasar setir & parkir aman',
      sessions: 5,
      price: 750000,
      features: [
        '5x Pertemuan (2 jam/sesi)',
        'Jemput langsung ke lokasi siswa',
        'Mobil ber-rem ganda standar LPK',
        'Rapor penilaian digital',
      ],
    ),
    const DrivingPackage(
      id: 'PKG-2',
      name: 'Paket Standar SIM A',
      description: 'Kurikulum lengkap + simulasi ujian & pendampingan SIM A',
      sessions: 10,
      price: 1500000,
      isPopular: true,
      features: [
        '10x Pertemuan (2 jam/sesi)',
        'Jemput langsung di radius Purwokerto',
        'Latihan tanjakan, jalan raya & parkir',
        'Ujian evaluasi & E-Sertifikat LPK',
        'Pendampingan proses SIM A Satpas',
      ],
    ),
    const DrivingPackage(
      id: 'PKG-3',
      name: 'Paket Intensif Pro',
      description: 'Cepat mahir 1-2 minggu dengan jadwal fleksibel prioritas',
      sessions: 15,
      price: 2100000,
      features: [
        '15x Pertemuan (2 jam/sesi)',
        'Instruktur prioritas & jadwal bebas',
        'Simulasi tol, malam hari & hujan',
        'E-Sertifikat resmi + Pendampingan SIM A',
      ],
    ),
  ];

  // Orders / Bookings (clean empty state for new beta accounts)
  final List<BookingOrder> orders = [];

  // Official 5-Module Curriculum (starts completely clean/unscored for every new student)
  final List<CurriculumModule> modules = [
    const CurriculumModule(
      id: 'MOD-1',
      title: 'Modul 1: Pengenalan & Ergonomi',
      subtitle: 'Panel instrumen, spion, posisi duduk & safety check',
      completed: false,
    ),
    const CurriculumModule(
      id: 'MOD-2',
      title: 'Modul 2: Dasar Setir & Pindah Gigi',
      subtitle: 'Koordinasi kopling-gas, belok halus & pengereman bertahap',
      completed: false,
    ),
    const CurriculumModule(
      id: 'MOD-3',
      title: 'Modul 3: Stop & Go Tanjakan',
      subtitle: 'Teknik rem tangan & setengah kopling di tanjakan',
      completed: false,
    ),
    const CurriculumModule(
      id: 'MOD-4',
      title: 'Modul 4: Parkir Seri, Paralel & Jalan Raya',
      subtitle: 'Manuver ruang sempit, lalu lintas padat & etika berkendara',
      completed: false,
    ),
    const CurriculumModule(
      id: 'MOD-5',
      title: 'Modul 5: Simulasi Ujian Teori & Praktik SIM A',
      subtitle: 'Uji rambu lalu lintas, lintasan zig-zag & kelayakan Satpas',
      completed: false,
    ),
  ];

  // Pending Mitra KYC for Admin (clean empty state)
  final List<PendingMitra> pendingMitras = [];

  // Graduations & Certificates for Admin & Siswa (clean empty state)
  final List<GraduationRecord> graduations = [];

  // Mitra Wallet History (clean empty state)
  final List<WalletTransaction> walletTransactions = [];

  // Admin Service Areas (master zone config, 0 dummy drivers)
  final List<ServiceAreaConfig> serviceAreas = [
    const ServiceAreaConfig(name: 'Purwokerto Utara', activeDrivers: 0, active: true),
    const ServiceAreaConfig(name: 'Purwokerto Timur', activeDrivers: 0, active: true),
    const ServiceAreaConfig(name: 'Purwokerto Selatan', activeDrivers: 0, active: true),
    const ServiceAreaConfig(name: 'Purwokerto Barat', activeDrivers: 0, active: true),
    const ServiceAreaConfig(name: 'Sokaraja', activeDrivers: 0, active: true),
    const ServiceAreaConfig(name: 'Baturraden', activeDrivers: 0, active: true),
  ];

  // Multi-LPK Registry (official HQ only, clean 0 metrics for beta)
  final List<LpkBranch> lpkBranches = [
    const LpkBranch(
      id: 'LPK-001',
      name: 'LPK Citra Indotech Jaya (HQ)',
      city: 'Purwokerto, Banyumas',
      licenseNumber: 'KEMNAKER/563/LPK-CIJ/2025',
      ownerName: 'Super Admin / LPK CIJ',
      ownerPhone: '0811-2600-0001',
      activeDrivers: 0,
      activeStudents: 0,
      monthlyOmzet: 0,
      status: 'verified',
    ),
  ];

  // ── Actions ──────────────────────────────────────────────────────

  void setRole(UserRole role) {
    currentRole = role;
    notifyListeners();
  }

  void login({
    required String name,
    required String email,
    required UserRole role,
    String username = '',
    String phone = '',
    bool superAdmin = false,
    bool master = false,
  }) {
    isLoggedIn = true;
    isSuperAdmin = superAdmin || master;
    isMaster = master;
    currentUsername = username.isNotEmpty ? username : email.split('@').first;
    userName = name;
    userEmail = email;
    if (phone.isNotEmpty) userPhone = phone;
    currentRole = role;
    if (role == UserRole.mitra) {
      final matchingPending = pendingMitras.where(
        (m) => m.name.toLowerCase() == name.toLowerCase(),
      );
      if (matchingPending.isNotEmpty) {
        mitraCarInfo = matchingPending.first.carInfo;
      }
    }
    notifyListeners();
  }

  void updateStudentProfile({
    required String fullName,
    required String phone,
    required String location,
    required String address,
    required String transmission,
  }) {
    if (fullName.trim().isNotEmpty) userName = fullName.trim();
    userPhone = phone.trim();
    studentLocation = location;
    studentAddress = address.trim();
    studentTransmission = transmission;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    isSuperAdmin = false;
    isMaster = false;
    currentUsername = '';
    userName = '';
    userEmail = '';
    userPhone = '';
    studentAddress = '';
    currentRole = UserRole.siswa;
    notifyListeners();
  }

  void setStudentLocation(String area) {
    studentLocation = area;
    notifyListeners();
  }

  /// Dana pembayaran siswa yang masih ditahan (escrow) hingga kursus mengemudi selesai.
  int get mitraEscrowBalance => orders
      .where((o) => o.stage != TripStage.completed && o.stage != TripStage.rejected)
      .fold<int>(0, (sum, o) => sum + o.mitraEarning);

  bool get hasOngoingCourse => orders.any(
        (o) => o.stage != TripStage.completed && o.stage != TripStage.rejected,
      );

  /// Saldo hanya bisa dicairkan ke rekening bank setelah kursus mengemudi selesai
  /// dan dana telah cair ke saldo mitra.
  bool get canWithdrawMitraWallet => mitraWalletBalance >= 100000;

  void toggleMitraOnline(bool val) {
    mitraIsOnline = val;
    for (int i = 0; i < instructors.length; i++) {
      final inst = instructors[i];
      if (userName.isNotEmpty && inst.name.toLowerCase() == userName.toLowerCase()) {
        instructors[i] = Instructor(
          id: inst.id,
          name: inst.name,
          initial: inst.initial,
          originDriver: inst.originDriver,
          carModel: inst.carModel,
          plateNumber: inst.plateNumber,
          rating: inst.rating,
          reviews: inst.reviews,
          distanceKm: inst.distanceKm,
          etaMinutes: inst.etaMinutes,
          transmissions: inst.transmissions,
          experienceYears: inst.experienceYears,
          sessionsCompleted: inst.sessionsCompleted,
          area: inst.area,
          isOnline: val,
          dualBrakeVerified: inst.dualBrakeVerified,
          mapX: inst.mapX,
          mapY: inst.mapY,
        );
      }
    }
    notifyListeners();
  }

  void setMitraRadius(double val) {
    mitraServiceRadius = val;
    notifyListeners();
  }

  void toggleMitraArea(String area) {
    if (mitraServiceAreas.contains(area)) {
      if (mitraServiceAreas.length > 1) mitraServiceAreas.remove(area);
    } else {
      mitraServiceAreas.add(area);
    }
    notifyListeners();
  }

  void createBooking({
    required Instructor instructor,
    required DrivingPackage package,
    required DateTime date,
    required String timeSlot,
    required String transmission,
    required String pickupAddress,
  }) {
    // Pembayaran siswa masuk ke dana ditahan (escrow) dan baru cair ke saldo mitra
    // setelah kursus mengemudi diselesaikan.
    final mitraTotalShare = (package.price * mitraSplitPercent / 100).round();
    final newOrder = BookingOrder(
      id: 'ORD-${9822 + orders.length}',
      studentName: userName,
      studentPhone: userPhone.isNotEmpty ? userPhone : '0812-3456-7890',
      pickupAddress: pickupAddress,
      distanceKm: instructor.distanceKm,
      instructorId: instructor.id,
      instructorName: instructor.name,
      carInfo: '${instructor.carModel} - ${instructor.plateNumber}',
      transmission: transmission,
      packageName: package.name,
      date: date,
      timeSlot: timeSlot,
      totalPrice: package.price,
      mitraEarning: mitraTotalShare,
      sessionIndex: 1,
      totalSessions: package.sessions,
      stage: TripStage.pending,
    );
    orders.insert(0, newOrder);
    notifyListeners();
  }

  void updateOrderStage(String orderId, TripStage newStage) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    if (order.stage == TripStage.completed) return;

    orders[idx] = order.copyWith(stage: newStage);

    // Dana kursus hanya cair ke saldo mitra setelah kursus mengemudi selesai.
    if (newStage == TripStage.completed) {
      mitraWalletBalance += order.mitraEarning;
      mitraMonthlySessions += order.totalSessions;
      walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'TRX-${walletTransactions.length + 10}',
          title: 'Kursus Selesai - ${order.studentName}',
          subtitle: 'Bagi hasil $mitraSplitPercent% (${order.packageName})',
          amount: order.mitraEarning,
          isCredit: true,
          dateLabel: 'Baru saja',
        ),
      );
    }
    notifyListeners();
  }

  void submitEvaluation({
    required String moduleId,
    required int score,
    required String notes,
  }) {
    final idx = modules.indexWhere((m) => m.id == moduleId);
    if (idx != -1) {
      modules[idx] = modules[idx].copyWith(
        completed: true,
        score: score,
        instructorNotes: notes,
      );
      notifyListeners();
    }
  }

  bool withdrawWallet(int amount, String bankTarget) {
    if (amount <= 0 || amount > mitraWalletBalance || !canWithdrawMitraWallet) {
      return false;
    }
    mitraWalletBalance -= amount;
    walletTransactions.insert(
      0,
      WalletTransaction(
        id: 'WD-${walletTransactions.length + 10}',
        title: 'Pencairan ke $bankTarget',
        subtitle: 'Transfer ke rekening bank mitra',
        amount: amount,
        isCredit: false,
        dateLabel: 'Baru saja',
      ),
    );
    notifyListeners();
    return true;
  }

  void registerNewMitraApplication({
    required String name,
    required String phone,
    required String carInfo,
    required String simType,
    required String area,
  }) {
    pendingMitras.insert(
      0,
      PendingMitra(
        id: 'MIT-0${pendingMitras.length + 10}',
        name: name,
        phone: phone,
        driverBackground: 'Mitra Driver Online Baru',
        simType: simType,
        carInfo: carInfo,
        area: area,
        status: 'pending',
      ),
    );
    notifyListeners();
  }

  void approveMitra(String id) {
    final idx = pendingMitras.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final m = pendingMitras[idx];
    pendingMitras[idx] = m.copyWith(status: 'approved');

    // Add newly approved mitra directly into the nearest-driver radar!
    if (!instructors.any((i) => i.name == m.name)) {
      final parts = m.carInfo.contains('•')
          ? m.carInfo.split('•')
          : m.carInfo.contains('-')
              ? m.carInfo.split('-')
              : [m.carInfo];
      final carModel = parts.first.trim();
      final plateNumber = parts.length > 1 ? parts.last.trim() : 'R 2026 LP';

      instructors.add(
        Instructor(
          id: m.id,
          name: m.name,
          initial: m.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join(),
          originDriver: m.driverBackground,
          carModel: carModel,
          plateNumber: plateNumber,
          rating: 5.0,
          reviews: 1,
          distanceKm: 3.1,
          etaMinutes: 10,
          transmissions: const ['Manual', 'Matic'],
          experienceYears: 5,
          sessionsCompleted: 1,
          area: m.area,
          isOnline: true,
          dualBrakeVerified: true,
          mapX: 0.48,
          mapY: 0.72,
        ),
      );
    }
    notifyListeners();
  }

  void approveGraduation(String id) {
    final idx = graduations.indexWhere((g) => g.id == id);
    if (idx != -1) {
      graduations[idx] = graduations[idx].copyWith(approved: true);
      notifyListeners();
    }
  }

  void updateSplit(int mitra, int lpk) {
    final platform = 100 - mitra - lpk;
    if (platform < 5) return;
    mitraSplitPercent = mitra;
    lpkSplitPercent = lpk;
    platformSplitPercent = platform;
    notifyListeners();
  }

  void toggleServiceArea(int index) {
    serviceAreas[index] = serviceAreas[index].copyWith(active: !serviceAreas[index].active);
    notifyListeners();
  }

  void setLpkBranchStatus(String id, String status) {
    final idx = lpkBranches.indexWhere((b) => b.id == id);
    if (idx != -1) {
      lpkBranches[idx] = lpkBranches[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  void registerLpkBranch({
    required String name,
    required String city,
    required String licenseNumber,
    required String ownerName,
    required String ownerPhone,
  }) {
    lpkBranches.insert(
      0,
      LpkBranch(
        id: 'LPK-00${lpkBranches.length + 1}',
        name: name,
        city: city,
        licenseNumber: licenseNumber,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        activeDrivers: 0,
        activeStudents: 0,
        monthlyOmzet: 0,
        status: 'pending',
      ),
    );
    notifyListeners();
  }

  int get totalBranchOmzet =>
      orders.where((o) => o.stage != TripStage.rejected).fold<int>(0, (sum, o) => sum + o.totalPrice);

  int get activeStudentCount => orders.map((o) => o.studentName).toSet().length;

  int get totalNationalOmzet =>
      totalBranchOmzet +
      lpkBranches.where((b) => b.status == 'verified').fold<int>(0, (sum, b) => sum + b.monthlyOmzet);

  int get totalNationalDrivers =>
      instructors.length +
      lpkBranches.where((b) => b.status == 'verified').fold<int>(0, (sum, b) => sum + b.activeDrivers);

  int get totalNationalStudents =>
      activeStudentCount +
      lpkBranches.where((b) => b.status == 'verified').fold<int>(0, (sum, b) => sum + b.activeStudents);

  double get studentAvgScore {
    final scored = modules.where((m) => m.score != null).toList();
    if (scored.isEmpty) return 0;
    return scored.fold<int>(0, (s, m) => s + m.score!) / scored.length;
  }

  bool get studentCertApproved {
    final rec = graduations.where((g) => g.studentName == userName).toList();
    return rec.isNotEmpty && rec.first.approved;
  }
}
