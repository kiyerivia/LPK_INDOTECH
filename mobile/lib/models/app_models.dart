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

/// Shared AppState connecting Siswa ↔ Mitra Driver ↔ Admin LPK in real-time
class AppState extends ChangeNotifier {
  UserRole currentRole = UserRole.siswa;
  bool isLoggedIn = false;
  bool isSuperAdmin = false;
  bool isMaster = false;
  String currentUsername = '';
  String userName = 'Dimas Aditya';
  String userEmail = 'siswa@lpk-cij.id';
  String studentLocation = 'Purwokerto Utara';

  // Smart Revenue Split (configurable by Admin LPK)
  int mitraSplitPercent = 60;
  int lpkSplitPercent = 27;
  int platformSplitPercent = 13;

  // Mitra Online Driver State
  bool mitraIsOnline = true;
  double mitraServiceRadius = 7.0;
  List<String> mitraServiceAreas = ['Purwokerto Utara', 'Purwokerto Timur', 'Baturraden'];
  int mitraWalletBalance = 2850000;
  int mitraMonthlySessions = 19;

  // Instructors (5 nearest drivers in Purwokerto ecosystem)
  final List<Instructor> instructors = [
    const Instructor(
      id: 'INS-01',
      name: 'Bambang Sugiantoro',
      initial: 'BS',
      originDriver: 'Mitra Eks GoCar • 8 thn',
      carModel: 'Toyota Avanza 1.3 G',
      plateNumber: 'R 1842 BS',
      rating: 4.9,
      reviews: 142,
      distanceKm: 1.2,
      etaMinutes: 4,
      transmissions: ['Manual', 'Matic'],
      experienceYears: 8,
      sessionsCompleted: 342,
      area: 'Purwokerto Utara',
      isOnline: true,
      dualBrakeVerified: true,
      mapX: 0.34,
      mapY: 0.30,
    ),
    const Instructor(
      id: 'INS-02',
      name: 'Dewi Anggraeni, S.Pd',
      initial: 'DA',
      originDriver: 'Mitra GrabCar Wanita • 5 thn',
      carModel: 'Honda Brio RS CVT',
      plateNumber: 'R 1290 DA',
      rating: 4.9,
      reviews: 98,
      distanceKm: 2.1,
      etaMinutes: 7,
      transmissions: ['Matic'],
      experienceYears: 5,
      sessionsCompleted: 215,
      area: 'Purwokerto Utara',
      isOnline: true,
      dualBrakeVerified: true,
      mapX: 0.68,
      mapY: 0.28,
    ),
    const Instructor(
      id: 'INS-03',
      name: 'Hendra Wijaya',
      initial: 'HW',
      originDriver: 'Mitra Maxim Car • 9 thn',
      carModel: 'Daihatsu Sigra R MT',
      plateNumber: 'R 1511 HW',
      rating: 4.8,
      reviews: 128,
      distanceKm: 2.8,
      etaMinutes: 9,
      transmissions: ['Manual'],
      experienceYears: 9,
      sessionsCompleted: 410,
      area: 'Purwokerto Timur',
      isOnline: true,
      dualBrakeVerified: true,
      mapX: 0.74,
      mapY: 0.62,
    ),
    const Instructor(
      id: 'INS-04',
      name: 'Ridwan Fauzi',
      initial: 'RF',
      originDriver: 'Mitra GoCar • 6 thn',
      carModel: 'Toyota Calya G AT',
      plateNumber: 'R 1774 RF',
      rating: 4.7,
      reviews: 76,
      distanceKm: 4.3,
      etaMinutes: 13,
      transmissions: ['Manual', 'Matic'],
      experienceYears: 6,
      sessionsCompleted: 185,
      area: 'Purwokerto Selatan',
      isOnline: true,
      dualBrakeVerified: true,
      mapX: 0.26,
      mapY: 0.70,
    ),
    const Instructor(
      id: 'INS-05',
      name: 'Agus Prasetyo',
      initial: 'AP',
      originDriver: 'Mitra Driver Online • 10 thn',
      carModel: 'Suzuki Ertiga GX MT',
      plateNumber: 'R 1903 AP',
      rating: 4.8,
      reviews: 110,
      distanceKm: 6.4,
      etaMinutes: 18,
      transmissions: ['Manual'],
      experienceYears: 10,
      sessionsCompleted: 480,
      area: 'Sokaraja',
      isOnline: true,
      dualBrakeVerified: true,
      mapX: 0.82,
      mapY: 0.78,
    ),
  ];

  // Packages
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

  // Orders / Bookings (shared between Siswa and Mitra!)
  final List<BookingOrder> orders = [
    BookingOrder(
      id: 'ORD-9821',
      studentName: 'Sarah Amelia (Unsoed)',
      studentPhone: '0857-1234-5678',
      pickupAddress: 'Jl. Kampus Grendeng No. 45, Purwokerto Utara',
      distanceKm: 1.8,
      instructorId: 'INS-01',
      instructorName: 'Bambang Sugiantoro',
      carInfo: 'Toyota Avanza • R 1842 BS',
      transmission: 'Manual',
      packageName: 'Paket Standar SIM A',
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '09:00 - 11:00 WIB',
      totalPrice: 1500000,
      mitraEarning: 90000,
      sessionIndex: 1,
      totalSessions: 10,
      stage: TripStage.pending,
    ),
    BookingOrder(
      id: 'ORD-9815',
      studentName: 'Dimas Aditya',
      studentPhone: '0812-3456-7890',
      pickupAddress: 'Perum Griya Satria, Purwokerto Utara',
      distanceKm: 1.2,
      instructorId: 'INS-01',
      instructorName: 'Bambang Sugiantoro',
      carInfo: 'Toyota Avanza • R 1842 BS',
      transmission: 'Manual',
      packageName: 'Paket Standar SIM A',
      date: DateTime.now().add(const Duration(hours: 3)),
      timeSlot: '14:00 - 16:00 WIB',
      totalPrice: 1500000,
      mitraEarning: 90000,
      sessionIndex: 4,
      totalSessions: 10,
      stage: TripStage.accepted,
    ),
    BookingOrder(
      id: 'ORD-9799',
      studentName: 'Dimas Aditya',
      studentPhone: '0812-3456-7890',
      pickupAddress: 'Perum Griya Satria, Purwokerto Utara',
      distanceKm: 1.2,
      instructorId: 'INS-01',
      instructorName: 'Bambang Sugiantoro',
      carInfo: 'Toyota Avanza • R 1842 BS',
      transmission: 'Manual',
      packageName: 'Paket Standar SIM A',
      date: DateTime.now().subtract(const Duration(days: 2)),
      timeSlot: '09:00 - 11:00 WIB',
      totalPrice: 1500000,
      mitraEarning: 90000,
      sessionIndex: 3,
      totalSessions: 10,
      stage: TripStage.completed,
    ),
  ];

  // Curriculum Modules for Siswa
  final List<CurriculumModule> modules = [
    const CurriculumModule(
      id: 'MOD-1',
      title: 'Modul 1: Pengenalan & Ergonomi',
      subtitle: 'Panel instrumen, spion, posisi duduk & safety check',
      completed: true,
      score: 92,
      instructorNotes: 'Sangat cepat memahami fungsi pedal dan pengaturan spion.',
    ),
    const CurriculumModule(
      id: 'MOD-2',
      title: 'Modul 2: Dasar Setir & Pindah Gigi',
      subtitle: 'Koordinasi kopling-gas, belok halus & pengereman bertahap',
      completed: true,
      score: 88,
      instructorNotes: 'Transisi gigi 1 ke 2 sudah halus, perhatikan RPM.',
    ),
    const CurriculumModule(
      id: 'MOD-3',
      title: 'Modul 3: Stop & Go Tanjakan',
      subtitle: 'Teknik rem tangan & setengah kopling di tanjakan Baturraden',
      completed: true,
      score: 90,
      instructorNotes: 'Tidak mundur saat tanjakan, mantap dan tenang.',
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

  // Pending Mitra KYC for Admin
  final List<PendingMitra> pendingMitras = [
    const PendingMitra(
      id: 'MIT-008',
      name: 'Rudi Hartono',
      phone: '0813-8822-1100',
      driverBackground: 'Eks Driver Maxim & GoCar (6 thn)',
      simType: 'SIM A Umum & SIM B1',
      carInfo: 'Toyota Calya G 2022 • R 4019 TR',
      area: 'Purwokerto Barat',
      status: 'pending',
    ),
    const PendingMitra(
      id: 'MIT-009',
      name: 'Fajar Nugroho',
      phone: '0856-4411-9022',
      driverBackground: 'Driver GrabCar Aktif (4 thn)',
      simType: 'SIM A Aktif s/d 2029',
      carInfo: 'Honda Mobilio E CVT • R 1622 FN',
      area: 'Sokaraja',
      status: 'pending',
    ),
  ];

  // Graduations & Certificates for Admin & Siswa
  final List<GraduationRecord> graduations = [
    const GraduationRecord(
      id: 'GRD-102',
      studentName: 'Dimas Aditya',
      instructorName: 'Bambang Sugiantoro',
      avgScore: 90.0,
      simStep: 'Siap Tes Satpas Polresta Banyumas',
      certNumber: 'LPK-IND/2026/SIM-A/0102',
      approved: true,
    ),
    const GraduationRecord(
      id: 'GRD-103',
      studentName: 'Nadia Safitri',
      instructorName: 'Dewi Anggraeni, S.Pd',
      avgScore: 95.0,
      simStep: 'Menunggu Otorisasi Sertifikat',
      certNumber: 'LPK-IND/2026/SIM-A/0103',
      approved: false,
    ),
  ];

  // Mitra Wallet History
  final List<WalletTransaction> walletTransactions = [
    const WalletTransaction(
      id: 'TRX-01',
      title: 'Insentif Sesi #3 — Dimas Aditya',
      subtitle: 'Smart Split 60% • Paket Standar',
      amount: 90000,
      isCredit: true,
      dateLabel: 'Kemarin, 11:05',
    ),
    const WalletTransaction(
      id: 'TRX-02',
      title: 'Insentif Sesi #8 — Raka Pratama',
      subtitle: 'Smart Split 60% • Paket Standar',
      amount: 90000,
      isCredit: true,
      dateLabel: '16 Nov, 16:10',
    ),
    const WalletTransaction(
      id: 'TRX-03',
      title: 'Penarikan ke BCA ****4821',
      subtitle: 'Pencairan Saldo Mitra',
      amount: 500000,
      isCredit: false,
      dateLabel: '14 Nov, 09:30',
    ),
  ];

  // Admin Service Areas
  final List<ServiceAreaConfig> serviceAreas = [
    const ServiceAreaConfig(name: 'Purwokerto Utara', activeDrivers: 9, active: true),
    const ServiceAreaConfig(name: 'Purwokerto Timur', activeDrivers: 7, active: true),
    const ServiceAreaConfig(name: 'Purwokerto Selatan', activeDrivers: 6, active: true),
    const ServiceAreaConfig(name: 'Purwokerto Barat', activeDrivers: 4, active: true),
    const ServiceAreaConfig(name: 'Sokaraja', activeDrivers: 3, active: true),
    const ServiceAreaConfig(name: 'Baturraden', activeDrivers: 2, active: true),
  ];

  // Multi-LPK Registry (Verified & Governed by INDOTECH Master)
  final List<LpkBranch> lpkBranches = [
    const LpkBranch(
      id: 'LPK-001',
      name: 'LPK Citra Indotech Jaya (HQ)',
      city: 'Purwokerto, Banyumas',
      licenseNumber: 'KEMNAKER/563/LPK-CIJ/2025',
      ownerName: 'Super Admin / LPK CIJ',
      ownerPhone: '0811-2600-0001',
      activeDrivers: 28,
      activeStudents: 64,
      monthlyOmzet: 48600000,
      status: 'verified',
    ),
    const LpkBranch(
      id: 'LPK-002',
      name: 'LPK Satria Muda Mengemudi',
      city: 'Cilacap Kota',
      licenseNumber: 'KEMNAKER/214/LPK-CLP/2026',
      ownerName: 'H. Sudirman',
      ownerPhone: '0813-2811-4400',
      activeDrivers: 12,
      activeStudents: 29,
      monthlyOmzet: 21500000,
      status: 'pending',
    ),
    const LpkBranch(
      id: 'LPK-003',
      name: 'LPK Prima Drive Purbalingga',
      city: 'Purbalingga',
      licenseNumber: 'KEMNAKER/118/LPK-PBG/2026',
      ownerName: 'Ibu Ratna Dewi',
      ownerPhone: '0856-9012-3311',
      activeDrivers: 8,
      activeStudents: 18,
      monthlyOmzet: 14200000,
      status: 'pending',
    ),
    const LpkBranch(
      id: 'LPK-004',
      name: 'LPK Mandala Kebumen',
      city: 'Kebumen',
      licenseNumber: 'KEMNAKER/092/LPK-KBM/2025',
      ownerName: 'Bapak Arifin',
      ownerPhone: '0812-7741-9900',
      activeDrivers: 15,
      activeStudents: 38,
      monthlyOmzet: 28900000,
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
    bool superAdmin = false,
    bool master = false,
  }) {
    isLoggedIn = true;
    isSuperAdmin = superAdmin || master;
    isMaster = master;
    currentUsername = username.isNotEmpty ? username : email.split('@').first;
    userName = name;
    userEmail = email;
    currentRole = role;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    isSuperAdmin = false;
    isMaster = false;
    currentUsername = '';
    userName = 'Dimas Aditya';
    currentRole = UserRole.siswa;
    notifyListeners();
  }

  void setStudentLocation(String area) {
    studentLocation = area;
    notifyListeners();
  }

  void toggleMitraOnline(bool val) {
    mitraIsOnline = val;
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
    final perSessionMitra = ((package.price * mitraSplitPercent / 100) / package.sessions).round();
    final newOrder = BookingOrder(
      id: 'ORD-${9822 + orders.length}',
      studentName: userName,
      studentPhone: '0812-3456-7890',
      pickupAddress: pickupAddress,
      distanceKm: instructor.distanceKm,
      instructorId: instructor.id,
      instructorName: instructor.name,
      carInfo: '${instructor.carModel} • ${instructor.plateNumber}',
      transmission: transmission,
      packageName: package.name,
      date: date,
      timeSlot: timeSlot,
      totalPrice: package.price,
      mitraEarning: perSessionMitra,
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
    orders[idx] = order.copyWith(stage: newStage);

    if (newStage == TripStage.completed) {
      mitraWalletBalance += order.mitraEarning;
      mitraMonthlySessions += 1;
      walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'TRX-${walletTransactions.length + 10}',
          title: 'Insentif Sesi #${order.sessionIndex} — ${order.studentName}',
          subtitle: 'Smart Split $mitraSplitPercent% • ${order.packageName}',
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

  void withdrawWallet(int amount, String bankTarget) {
    if (amount <= 0 || amount > mitraWalletBalance) return;
    mitraWalletBalance -= amount;
    walletTransactions.insert(
      0,
      WalletTransaction(
        id: 'WD-${walletTransactions.length + 10}',
        title: 'Penarikan ke $bankTarget',
        subtitle: 'Diproses Instan LPK Pay',
        amount: amount,
        isCredit: false,
        dateLabel: 'Baru saja',
      ),
    );
    notifyListeners();
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
      instructors.add(
        Instructor(
          id: m.id,
          name: m.name,
          initial: m.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join(),
          originDriver: m.driverBackground,
          carModel: m.carInfo.split('•').first.trim(),
          plateNumber: m.carInfo.contains('•') ? m.carInfo.split('•').last.trim() : 'R 2026 LP',
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

  int get totalNationalOmzet =>
      lpkBranches.where((b) => b.status == 'verified').fold<int>(0, (sum, b) => sum + b.monthlyOmzet);

  int get totalNationalDrivers =>
      lpkBranches.where((b) => b.status == 'verified').fold<int>(0, (sum, b) => sum + b.activeDrivers);

  int get totalNationalStudents =>
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
