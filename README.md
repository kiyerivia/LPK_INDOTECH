# 🚗 LPK INDOTECH - Driving Partner Platform

Platform pelatihan dan kursus mengemudi modern berbasis ekosistem kemitraan instruktur lapangan terdekat, kurikulum resmi terstandar, dan sertifikasi kompetensi.

![React](https://img.shields.io/badge/React-19-blue?style=for-the-badge&logo=react)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-v4-38bdf8?style=for-the-badge&logo=tailwindcss)
![Framer Motion](https://img.shields.io/badge/Framer_Motion-Animation-ff0055?style=for-the-badge&logo=framer)
![Vite](https://img.shields.io/badge/Vite-8.3-646cff?style=for-the-badge&logo=vite)

---

## ✨ Fitur Unggulan

### 1. 👥 Multi-Role Ecosystem (3 Jenis Pengguna)
* **Siswa / Konsumen**:
  * **Radar Instruktur Terdekat**: Deteksi otomatis instruktur aktif dalam radius 3–10 km di area Purwokerto & sekitarnya.
  * **Filter Mobil**: Pilihan transmisi **Manual** atau **Matic**, serta mobil yang tersertifikasi memiliki **Pedal Rem Ganda Resmi**.
  * **Booking Jadwal & Door-to-Door**: Pilih hari dan slot waktu dengan proteksi jeda perjalanan (*buffer time* 30 menit) antar siswa.
  * **Rapor Belajar Digital**: Evaluasi penguasaan modul bertahap (Kokpit, Haluan, Stop & Go Tanjakan Baturraden, Master Parkir Seri & Paralel, Ujian LPK).
  * **E-Sertifikat Resmi**: Otorisasi sertifikat kompetensi berstandar Kemnaker lengkap dengan nomor registrasi dan QR Code verifikasi.
  * **Profil Siswa**: Manajemen alamat jemput (rumah, kost, kampus), invoice pembayaran, dan panduan teknik menyetir.

* **Mitra Driver / Instruktur Lapangan**:
  * **Mode Siaga**: Toggle status online/offline untuk menerima pesanan latihan.
  * **Dispatching Order Masuk**: Notifikasi pesanan lengkap dengan nama siswa, titik jemput, waktu, dan estimasi penghasilan.
  * **Evaluasi Lapangan**: Pengisian nilai dan checklist keterampilan siswa langsung dari aplikasi setelah sesi selesai.
  * **Dompet Mitra**: Transparansi komisi bagi hasil **60%** langsung masuk ke saldo dompet.

* **Admin LPK Indotech (Pusat Kendali)**:
  * **Dashboard Omzet & Operasional**: Monitoring kas masuk, performa sesi, dan pertumbuhan siswa.
  * **Verifikasi Mitra (KYC & Safety Check)**: Validasi SIM A/B1 dan uji kelayakan fisik rem ganda kendaraan mitra.
  * **Otorisasi Kelulusan**: Penerbitan nomor sertifikat resmi LPK berakreditasi.

---

### 🎨 Desain & UI/UX
* **Glassmorphism Dark Mode**: Desain modern berbasis *frosted glass* berlapis, *backdrop blur*, dan ambient glow neon.
* **Floating Navbar with Animated Neon Arch**: Navbar melayang di bagian bawah dengan indikator lengkungan neon fluid (*bell-curve arch*) yang bergerak dinamis mengikuti tab aktif menggunakan **Framer Motion**, serta *floating search popup*.

---

### 💰 Model Bisnis (Smart Split Payment)
Setiap sesi atau paket pelatihan secara otomatis dibagi dengan sistem bagi hasil transparan:
* **60%**: Mitra Instruktur (Jasa mengajar, BBM, perawatan mobil, insentif keselamatan).
* **27%**: LPK Indotech (Akreditasi, kurikulum, pendampingan ujian SIM di Satpas, sertifikat resmi).
* **13%**: Platform & Asuransi (Operasional server, matching radius GPS, proteksi asuransi keselamatan latihan).

---

## 🛠️ Instalasi & Menjalankan Proyek

1. **Clone repository:**
   ```bash
   git clone https://github.com/kiyerivia/LPK_INDOTECH.git
   cd LPK_INDOTECH
   ```

2. **Install dependensi:**
   ```bash
   npm install
   ```

3. **Jalankan development server:**
   ```bash
   npm run dev
   ```
   Aplikasi akan berjalan di `http://localhost:5173/`.

4. **Build untuk production:**
   ```bash
   npm run build
   ```

---

© 2026 **LPK INDOTECH** - Hak Cipta Dilindungi.
