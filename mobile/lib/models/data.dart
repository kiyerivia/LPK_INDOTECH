class Instruktur {
  final String id;
  final String nama;
  final String foto;
  final double rating;
  final int ulasan;
  final double jarak; // km
  final List<String> transmisi;
  final int pengalaman; // tahun
  final int sesiSelesai;
  final String wilayah;
  final bool online;
  final bool remGanda;

  const Instruktur({
    required this.id,
    required this.nama,
    required this.foto,
    required this.rating,
    required this.ulasan,
    required this.jarak,
    required this.transmisi,
    required this.pengalaman,
    required this.sesiSelesai,
    required this.wilayah,
    required this.online,
    this.remGanda = true,
  });
}

class PaketLatihan {
  final String id;
  final String nama;
  final String deskripsi;
  final int sesi;
  final int harga;
  final List<String> fitur;
  final bool terpopuler;

  const PaketLatihan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.sesi,
    required this.harga,
    required this.fitur,
    this.terpopuler = false,
  });
}

class Booking {
  final String id;
  final String instrukturId;
  final String instrukturNama;
  final String paketNama;
  final DateTime tanggal;
  final String jam;
  final String status; // menunggu, dikonfirmasi, berlangsung, selesai, dibatalkan
  final int totalBayar;
  final int sesiKe;
  final int totalSesi;

  const Booking({
    required this.id,
    required this.instrukturId,
    required this.instrukturNama,
    required this.paketNama,
    required this.tanggal,
    required this.jam,
    required this.status,
    required this.totalBayar,
    required this.sesiKe,
    required this.totalSesi,
  });
}

// ── Mock Data ──────────────────────────────────────────────────────

const List<Instruktur> mockInstruktur = [
  Instruktur(
    id: '1',
    nama: 'Pak Hendra Wijaya',
    foto: 'H',
    rating: 4.9,
    ulasan: 128,
    jarak: 1.2,
    transmisi: ['Manual', 'Matic'],
    pengalaman: 8,
    sesiSelesai: 342,
    wilayah: 'Purwokerto Utara',
    online: true,
    remGanda: true,
  ),
  Instruktur(
    id: '2',
    nama: 'Bu Sari Dewi',
    foto: 'S',
    rating: 4.8,
    ulasan: 95,
    jarak: 2.5,
    transmisi: ['Matic'],
    pengalaman: 5,
    sesiSelesai: 210,
    wilayah: 'Purwokerto Selatan',
    online: true,
    remGanda: true,
  ),
  Instruktur(
    id: '3',
    nama: 'Pak Budi Santoso',
    foto: 'B',
    rating: 4.7,
    ulasan: 73,
    jarak: 3.8,
    transmisi: ['Manual'],
    pengalaman: 10,
    sesiSelesai: 480,
    wilayah: 'Purwokerto Timur',
    online: false,
    remGanda: true,
  ),
  Instruktur(
    id: '4',
    nama: 'Pak Ridwan Fauzi',
    foto: 'R',
    rating: 4.6,
    ulasan: 56,
    jarak: 4.9,
    transmisi: ['Manual', 'Matic'],
    pengalaman: 6,
    sesiSelesai: 185,
    wilayah: 'Sokaraja',
    online: true,
    remGanda: true,
  ),
];

const List<PaketLatihan> mockPaket = [
  PaketLatihan(
    id: '1',
    nama: 'Paket Pemula',
    deskripsi: 'Cocok untuk yang baru pertama kali belajar mengemudi',
    sesi: 5,
    harga: 750000,
    fitur: ['5 sesi latihan', '2 jam/sesi', 'Teori dasar', 'Latihan parkir', 'Sertifikat kelulusan'],
    terpopuler: false,
  ),
  PaketLatihan(
    id: '2',
    nama: 'Paket Standar',
    deskripsi: 'Paket terlengkap untuk persiapan ujian SIM',
    sesi: 10,
    harga: 1500000,
    fitur: ['10 sesi latihan', '2 jam/sesi', 'Teori + Praktik lengkap', 'Simulasi ujian SIM', 'Latihan di berbagai medan', 'Sertifikat kelulusan', 'Konsultasi SIM gratis'],
    terpopuler: true,
  ),
  PaketLatihan(
    id: '3',
    nama: 'Paket Intensif',
    deskripsi: 'Belajar cepat dalam 1 minggu',
    sesi: 15,
    harga: 2100000,
    fitur: ['15 sesi latihan', '2 jam/sesi', 'Jadwal fleksibel', 'Instruktur dedicated', 'Simulasi ujian SIM', 'Pendampingan ujian SIM', 'Sertifikat kelulusan'],
    terpopuler: false,
  ),
];

final List<Booking> mockBooking = [
  Booking(
    id: 'BK001',
    instrukturId: '1',
    instrukturNama: 'Pak Hendra Wijaya',
    paketNama: 'Paket Standar',
    tanggal: DateTime.now().add(const Duration(days: 1)),
    jam: '09:00',
    status: 'dikonfirmasi',
    totalBayar: 1500000,
    sesiKe: 3,
    totalSesi: 10,
  ),
  Booking(
    id: 'BK002',
    instrukturId: '1',
    instrukturNama: 'Pak Hendra Wijaya',
    paketNama: 'Paket Standar',
    tanggal: DateTime.now().subtract(const Duration(days: 2)),
    jam: '14:00',
    status: 'selesai',
    totalBayar: 1500000,
    sesiKe: 2,
    totalSesi: 10,
  ),
];
