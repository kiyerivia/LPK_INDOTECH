export const INSTRUCTORS = [
  {
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
    experienceYears: 7,
    status: 'Tersedia Sekarang',
    hourlyRate: 85000,
    tags: ['Sabar Banget', 'Pakar Parkir', 'Spesialis Pemula'],
    availableSlots: ['08:00 - 10:00', '10:30 - 12:30', '14:00 - 16:00', '16:30 - 18:30'],
    bio: 'Instruktur bersertifikasi resmi LPK Indotech. Telah meluluskan 140+ siswa mahir berkendara aman tanpa rasa takut.'
  },
  {
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
    experienceYears: 5,
    status: 'Tersedia Sekarang',
    hourlyRate: 90000,
    tags: ['Instruktur Wanita', 'Sangat Ramah', 'Favorit Siswi'],
    availableSlots: ['09:00 - 11:00', '13:00 - 15:00', '15:30 - 17:30'],
    bio: 'Instruktur perempuan ramah, sabar membimbing siswi dari nol hingga percaya diri mengemudi di jalan protokol.'
  },
  {
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
    experienceYears: 9,
    status: 'Ada Sesi Jam 14:00',
    hourlyRate: 80000,
    tags: ['Master Tanjakan', 'Rute Luar Kota', 'Spesialis Kopling'],
    availableSlots: ['07:30 - 09:30', '16:00 - 18:00'],
    bio: 'Spesialis rute tanjakan curam Baturraden dan jalanan sempit perumahan. Membantu melatih refleks dan ketenangan.'
  },
  {
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
    experienceYears: 6,
    status: 'Tersedia Sekarang',
    hourlyRate: 85000,
    tags: ['Spesialis Ujian SIM A', 'Disiplin', 'Pakar Parkir Mall'],
    availableSlots: ['08:00 - 10:00', '13:30 - 15:30', '16:00 - 18:00'],
    bio: 'Berpengalaman mendampingi ujian SIM A di Satpas. Mengajarkan trik parkir paralel akurat dalam sekali manuver.'
  }
];

export const PACKAGES = [
  {
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
      'Jemput Langsung di Rumah Siswa (Door to Door)',
      'Instruktur Terdekat & Bersertifikat',
      'Garansi Belajar Sampai Mahir',
      'Pendampingan Tes Teori & Praktik SIM A',
      'Sertifikat Kelulusan Resmi LPK INDOTECH'
    ],
    split: {
      instructor: 900000,
      lpk: 400000,
      platform: 200000
    }
  },
  {
    id: 'pkg-express',
    title: 'Paket Mahir Kilat (6 Jam)',
    subtitle: 'Khusus yang Sudah Tahu Dasar & Ingin Memperlancar',
    sessions: 3,
    hoursTotal: 6,
    price: 950000,
    popular: false,
    features: [
      '3 Sesi Pertemuan @ 2 Jam',
      'Fokus Parkir Sempit & Tanjakan Ekstrem',
      'Latihan Jam Sibuk & Lalu Lintas Padat Kota',
      'Jemput Langsung di Rumah Siswa',
      'Sertifikat Pelatihan LPK Indotech'
    ],
    split: {
      instructor: 570000,
      lpk: 260000,
      platform: 120000
    }
  },
  {
    id: 'pkg-complete',
    title: 'Paket Komplit Siap SIM A (14 Jam)',
    subtitle: 'Paket Lengkap + Simulasi Lintasan Uji Satpas',
    sessions: 7,
    hoursTotal: 14,
    price: 1950000,
    popular: false,
    badge: 'Paling Lengkap',
    features: [
      '7 Sesi Pertemuan @ 2 Jam (Total 14 Jam)',
      'Penguasaan Jalan Raya Kota & Jalur Luar Kota',
      'Simulasi Lintasan Uji SIM A (Tanjakan, Zig-zag, Parkir L)',
      'Free Tryout Soal Teori SIM A Online di Aplikasi',
      'Pendampingan Resmi LPK ke Satpas Polresta',
      'Sertifikat Resmi Berakreditasi Kemnaker'
    ],
    split: {
      instructor: 1170000,
      lpk: 520000,
      platform: 260000
    }
  }
];

export const CURRICULUM_MODULES = [
  {
    id: 1,
    title: 'Modul 1: Pengenalan Kokpit & Kontrol Pedal',
    description: 'Pengaturan kursi, spion, pengenalan kopling/gas/rem, titik setengah kopling (clutch point).',
    status: 'completed',
    score: 95,
    instructorNotes: 'Siswa sangat tenang, feeling pedal gas dan rem sudah halus.',
    date: '12 Nov 2026'
  },
  {
    id: 2,
    title: 'Modul 2: Manuver Belok & Haluan Jalan Sempit',
    description: 'Teknik hand-over-hand, feeling dimensi bodi mobil, melintasi persimpangan dan gang.',
    status: 'completed',
    score: 90,
    instructorNotes: 'Sudah berani putar balik di jalan 2 lajur. Spion kiri perlu lebih sering dipantau.',
    date: '14 Nov 2026'
  },
  {
    id: 3,
    title: 'Modul 3: Stop & Go di Tanjakan Terjal (Baturraden)',
    description: 'Teknik rem tangan di tanjakan, setengah kopling tanpa mundur, dan akselerasi tanjakan.',
    status: 'in_progress',
    score: 85,
    instructorNotes: 'Latihan tanjakan berjalan lancar. Latihan 1x lagi untuk memantapkan refleks.',
    date: 'Hari ini'
  },
  {
    id: 4,
    title: 'Modul 4: Master Parkir (Seri, Paralel & Sudut)',
    description: 'Teknik patokan pilar mobil, rumus putar setir mundur, dan parkir mall/paralel sempit.',
    status: 'upcoming',
    score: null,
    instructorNotes: 'Jadwal sesi berikutnya.',
    date: 'Besok, 10:00'
  },
  {
    id: 5,
    title: 'Modul 5: Ujian Akhir LPK & Simulasi Ujian SIM',
    description: 'Evaluasi independen kelulusan LPK, zig-zag, angka 8, dan ujian jalan raya.',
    status: 'upcoming',
    score: null,
    instructorNotes: 'Ujian penentu sertifikat kelulusan LPK Indotech.',
    date: '19 Nov 2026'
  }
];
