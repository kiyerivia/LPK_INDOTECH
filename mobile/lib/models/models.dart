class Instructor {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final String locationName;
  final String transmission;
  final String carModel;
  final String carPlate;
  final String dualPedal;
  final int hourlyRate;
  final List<String> availableSlots;
  final String bio;

  Instructor({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.locationName,
    required this.transmission,
    required this.carModel,
    required this.carPlate,
    required this.dualPedal,
    required this.hourlyRate,
    required this.availableSlots,
    required this.bio,
  });
}

class DrivingPackage {
  final String id;
  final String title;
  final String subtitle;
  final int sessions;
  final int hoursTotal;
  final int price;
  final bool popular;
  final String? badge;
  final List<String> features;
  final int instructorFee;
  final int lpkFee;
  final int platformFee;

  DrivingPackage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sessions,
    required this.hoursTotal,
    required this.price,
    this.popular = false,
    this.badge,
    required this.features,
    required this.instructorFee,
    required this.lpkFee,
    required this.platformFee,
  });
}

class CurriculumModule {
  final int id;
  final String title;
  final String description;
  final String status; // 'completed', 'in_progress', 'upcoming'
  final int? score;
  final String? instructorNotes;
  final String date;

  CurriculumModule({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.score,
    this.instructorNotes,
    required this.date,
  });
}

// Global Static Mock Data
final List<Instructor> mockInstructors = [
  Instructor(
    id: 'inst-1',
    name: 'Bambang Sugiantoro',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    rating: 4.9,
    reviewsCount: 142,
    distanceKm: 1.8,
    locationName: 'Grendeng, Purwokerto Utara',
    transmission: 'Manual & Matic',
    carModel: 'Toyota All New Avanza (2023)',
    carPlate: 'R 1842 BS',
    dualPedal: 'Rem & Kopling Ganda Tersertifikasi',
    hourlyRate: 85000,
    availableSlots: ['08:00 - 10:00', '10:30 - 12:30', '14:00 - 16:00', '16:30 - 18:30'],
    bio: 'Instruktur bersertifikasi resmi LPK Indotech. Telah meluluskan 140+ siswa mahir tanpa rasa takut.',
  ),
  Instructor(
    id: 'inst-2',
    name: 'Dewi Anggraeni, S.Pd',
    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
    rating: 5.0,
    reviewsCount: 98,
    distanceKm: 2.4,
    locationName: 'Karangwangkal, Purwokerto Utara',
    transmission: 'Matic Only',
    carModel: 'Honda Brio RS CVT (2024)',
    carPlate: 'R 9920 DA',
    dualPedal: 'Rem Ganda Hidrolik LPK',
    hourlyRate: 90000,
    availableSlots: ['09:00 - 11:00', '13:00 - 15:00', '15:30 - 17:30'],
    bio: 'Instruktur perempuan ramah, membimbing siswi dari nol hingga percaya diri di jalan raya.',
  ),
  Instructor(
    id: 'inst-3',
    name: 'Hendra Prasetyo',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
    rating: 4.8,
    reviewsCount: 215,
    distanceKm: 3.5,
    locationName: 'Bancarkembar, Purwokerto Utara',
    transmission: 'Manual Only',
    carModel: 'Suzuki All New Ertiga (2022)',
    carPlate: 'R 3412 HP',
    dualPedal: 'Dual Pedal System Resmi',
    hourlyRate: 80000,
    availableSlots: ['07:30 - 09:30', '16:00 - 18:00'],
    bio: 'Spesialis rute tanjakan curam Baturraden dan jalanan sempit perumahan.',
  ),
  Instructor(
    id: 'inst-4',
    name: 'Ahmad Fauzi',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
    rating: 4.9,
    reviewsCount: 76,
    distanceKm: 4.1,
    locationName: 'Dukuhwaluh, Kembaran',
    transmission: 'Manual & Matic',
    carModel: 'Daihatsu All New Xenia (2023)',
    carPlate: 'R 2109 AF',
    dualPedal: 'Dual Brake Support LPK',
    hourlyRate: 85000,
    availableSlots: ['08:00 - 10:00', '13:30 - 15:30', '16:00 - 18:00'],
    bio: 'Pakar ujian SIM A di Satpas. Mengajarkan trik parkir paralel akurat sekali manuver.',
  ),
];

final List<DrivingPackage> mockPackages = [
  DrivingPackage(
    id: 'pkg-basic',
    title: 'Paket Dasar Pemula (10 Jam)',
    subtitle: 'Dari Nol sampai Lancar Jalan Raya',
    sessions: 5,
    hoursTotal: 10,
    price: 1500000,
    popular: true,
    features: [
      '5 Sesi Pertemuan @ 2 Jam',
      'Pilihan Mobil Manual / Matic',
      'Jemput di Rumah (Door to Door)',
      'Garansi Belajar Sampai Mahir',
      'Pendampingan Tes SIM A',
      'Sertifikat Resmi LPK INDOTECH',
    ],
    instructorFee: 900000,
    lpkFee: 400000,
    platformFee: 200000,
  ),
  DrivingPackage(
    id: 'pkg-express',
    title: 'Paket Mahir Kilat (6 Jam)',
    subtitle: 'Khusus Pemantapan Parkir & Tanjakan',
    sessions: 3,
    hoursTotal: 6,
    price: 950000,
    popular: false,
    features: [
      '3 Sesi Pertemuan @ 2 Jam',
      'Fokus Parkir Sempit & Tanjakan Ekstrem',
      'Latihan Jam Sibuk Kota',
      'Jemput Langsung di Rumah',
      'Sertifikat Pelatihan LPK',
    ],
    instructorFee: 570000,
    lpkFee: 260000,
    platformFee: 120000,
  ),
  DrivingPackage(
    id: 'pkg-complete',
    title: 'Paket Komplit Siap SIM A (14 Jam)',
    subtitle: 'Paket Lengkap + Simulasi Lintasan Satpas',
    sessions: 7,
    hoursTotal: 14,
    price: 1950000,
    popular: false,
    badge: 'Paling Lengkap',
    features: [
      '7 Sesi Pertemuan @ 2 Jam',
      'Penguasaan Jalur Luar Kota',
      'Simulasi Lintasan Uji SIM A',
      'Free Tryout Teori Satpas Online',
      'Pendampingan Resmi LPK ke Satpas',
      'Sertifikat Resmi Kemnaker RI',
    ],
    instructorFee: 1170000,
    lpkFee: 520000,
    platformFee: 260000,
  ),
];

final List<CurriculumModule> mockModules = [
  CurriculumModule(
    id: 1,
    title: 'Modul 1: Kokpit & Kontrol Pedal',
    description: 'Setengah kopling, pengaturan spion, dan feeling rem/gas.',
    status: 'completed',
    score: 95,
    instructorNotes: 'Siswa sangat tenang, feeling pedal halus.',
    date: '12 Nov 2026',
  ),
  CurriculumModule(
    id: 2,
    title: 'Modul 2: Manuver Belok & Haluan',
    description: 'Teknik hand-over-hand dan dimensi bodi mobil.',
    status: 'completed',
    score: 90,
    instructorNotes: 'Sudah berani putar balik di jalan 2 lajur.',
    date: '14 Nov 2026',
  ),
  CurriculumModule(
    id: 3,
    title: 'Modul 3: Stop & Go Tanjakan Baturraden',
    description: 'Teknik rem tangan di tanjakan terjal tanpa mundur.',
    status: 'in_progress',
    score: 85,
    instructorNotes: 'Latihan tanjakan berjalan lancar, mantapkan refleks.',
    date: 'Hari ini',
  ),
  CurriculumModule(
    id: 4,
    title: 'Modul 4: Master Parkir Seri & Paralel',
    description: 'Rumus pilar mobil dan patokan mundur parkir sempit.',
    status: 'upcoming',
    score: null,
    instructorNotes: 'Jadwal sesi berikutnya.',
    date: 'Besok, 10:00',
  ),
  CurriculumModule(
    id: 5,
    title: 'Modul 5: Ujian Kelulusan LPK & SIM A',
    description: 'Evaluasi independen, zig-zag, dan ujian jalan raya.',
    status: 'upcoming',
    score: null,
    instructorNotes: 'Ujian penentu sertifikat kelulusan LPK.',
    date: '19 Nov 2026',
  ),
];
