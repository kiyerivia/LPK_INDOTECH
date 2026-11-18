import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  User, 
  MapPin, 
  Phone, 
  CreditCard, 
  ShieldCheck, 
  HelpCircle, 
  FileText, 
  Car, 
  CheckCircle2, 
  ChevronRight, 
  ExternalLink,
  BookOpen,
  Building2,
  Clock
} from 'lucide-react';

export default function ProfilSiswa({ onNavigate }) {
  const [activeFaq, setActiveFaq] = useState(null);

  const faqs = [
    {
      q: 'Bagaimana jika mobil lecet atau terjadi insiden saat saya belajar?',
      a: 'Seluruh armada mitra LPK Indotech dilindungi oleh asuransi pelatihan dan dilengkapi pedal rem ganda darurat yang dipegang oleh instruktur. Siswa tidak dibebankan biaya ganti rugi selama mengikuti instruksi pelatih.'
    },
    {
      q: 'Bisakah saya ganti jadwal jika berhalangan hadir?',
      a: 'Bisa! Anda dapat melakukan reschedule paling lambat H-3 jam sebelum sesi dimulai langsung melalui tab Jadwal di aplikasi tanpa biaya tambahan.'
    },
    {
      q: 'Apakah sertifikat LPK Indotech bisa digunakan untuk berkas pengurusan SIM?',
      a: 'Tentu. LPK Indotech terakreditasi resmi dan sertifikat kelulusan kami diakui sebagai bukti telah mengikuti pelatihan mengemudi resmi saat pengurusan SIM A di Satpas Polri.'
    }
  ];

  return (
    <div className="space-y-6 pb-28">
      {/* Header Profile Card */}
      <div className="glass-card rounded-3xl p-5 sm:p-6 border border-white/10 relative overflow-hidden">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl bg-gradient-to-tr from-rose-600 to-rose-400 p-0.5 shadow-lg">
              <div className="w-full h-full rounded-2xl bg-zinc-950 flex items-center justify-center text-rose-400">
                <User className="w-9 h-9" />
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <h1 className="text-base sm:text-xl font-bold text-white">
                  Dimas Aditya Pratama
                </h1>
                <span className="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2 py-0.5 rounded-full font-bold">
                  Siswa Aktif
                </span>
              </div>
              <p className="text-xs text-zinc-400 font-mono">
                ID Siswa: <span className="text-zinc-200">LPK-2026-0941</span> • Purwokerto Utara
              </p>
              <p className="text-xs text-rose-400 font-medium flex items-center gap-1.5 pt-0.5">
                <Car className="w-3.5 h-3.5" />
                Paket Dasar Pemula (Manual) • 3 dari 5 Sesi Selesai
              </p>
            </div>
          </div>

          <div className="flex sm:flex-col gap-2 shrink-0">
            <button
              onClick={() => onNavigate('progress')}
              className="flex-1 sm:flex-none px-4 py-2 rounded-xl bg-zinc-800 hover:bg-zinc-700 text-xs font-semibold text-white border border-white/10 transition cursor-pointer"
            >
              Lihat Rapor
            </button>
            <button
              onClick={() => onNavigate('schedule')}
              className="flex-1 sm:flex-none px-4 py-2 rounded-xl bg-rose-500 hover:bg-rose-600 text-xs font-bold text-white shadow-[0_0_15px_rgba(244,63,94,0.4)] transition cursor-pointer"
            >
              Jadwal Sesi
            </button>
          </div>
        </div>
      </div>

      {/* Titik Jemput Tersimpan (Door-to-door location) */}
      <div className="glass-card rounded-2xl p-5 border border-white/10 space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
            <MapPin className="w-4 h-4 text-rose-400" />
            Alamat Penjemputan Tersimpan
          </h3>
          <span className="text-[11px] text-zinc-400">Instruktur jemput langsung</span>
        </div>

        <div className="space-y-2">
          <div className="bg-zinc-900/80 p-3 rounded-xl border border-rose-500/30 flex items-start justify-between gap-3">
            <div className="space-y-0.5">
              <div className="flex items-center gap-2">
                <span className="text-xs font-bold text-white">Kost / Rumah (Utama)</span>
                <span className="text-[9px] bg-rose-500/20 text-rose-300 px-1.5 py-0.5 rounded font-mono">
                  Default
                </span>
              </div>
              <p className="text-xs text-zinc-300">
                Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara, Banyumas
              </p>
              <span className="text-[10px] text-zinc-500">Patokan: Sebelah barat lapangan Grendeng</span>
            </div>
            <span className="text-xs text-emerald-400 font-semibold shrink-0">Terpilih</span>
          </div>

          <div className="bg-zinc-900/40 p-3 rounded-xl border border-white/5 flex items-start justify-between gap-3">
            <div className="space-y-0.5">
              <span className="text-xs font-bold text-zinc-300">Kampus / Kantor</span>
              <p className="text-xs text-zinc-400">
                Gedung FISIP Unsoed, Jl. HR Boenyamin, Purwokerto Utara
              </p>
            </div>
            <button className="text-xs text-rose-400 hover:underline shrink-0 cursor-pointer">
              Gunakan
            </button>
          </div>
        </div>
      </div>

      {/* Riwayat Pembayaran & Transparansi */}
      <div className="glass-card rounded-2xl p-5 border border-white/10 space-y-3">
        <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <CreditCard className="w-4 h-4 text-rose-400" />
          Riwayat Pembayaran & Invoice
        </h3>

        <div className="bg-zinc-900/60 p-4 rounded-xl border border-white/5 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-xs font-bold text-white">Paket Dasar Pemula (10 Jam)</span>
              <span className="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2 py-0.5 rounded-full font-bold">
                LUNAS
              </span>
            </div>
            <p className="text-xs text-zinc-400">
              Metode: QRIS Auto • No. Transaksi: <span className="font-mono text-zinc-300">INV/LPK/2026/0921</span>
            </p>
            <span className="text-[11px] text-zinc-500">11 Nov 2026, 14:22 WIB</span>
          </div>

          <div className="flex items-center justify-between sm:justify-end gap-3 border-t sm:border-t-0 border-white/5 pt-2 sm:pt-0">
            <div className="text-right">
              <span className="text-sm font-extrabold text-white">Rp 1.500.000</span>
            </div>
            <button
              onClick={() => alert('Mengunduh bukti pembayaran / invoice resmi LPK INDOTECH (PDF)...')}
              className="px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 text-xs font-medium border border-white/10 flex items-center gap-1.5 transition cursor-pointer"
            >
              <FileText className="w-3.5 h-3.5" />
              Invoice
            </button>
          </div>
        </div>
      </div>

      {/* Tips & Panduan Mengemudi LPK */}
      <div className="glass-card rounded-2xl p-5 border border-white/10 space-y-3">
        <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-rose-400" />
          Tips & Panduan Mengemudi LPK Indotech
        </h3>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
          <div className="bg-zinc-900/60 p-3.5 rounded-xl border border-white/5 space-y-1">
            <span className="font-bold text-rose-400 block">1. Kunci Utama Tanjakan Curam</span>
            <p className="text-zinc-300 leading-relaxed">
              Tarik rem tangan kuat-kuat, injak kopling penuh & masuk gigi 1. Tekan gas hingga 2000 RPM, angkat kopling pelan sampai moncong mobil terasa terangkat, lalu lepas rem tangan perlahan.
            </p>
          </div>

          <div className="bg-zinc-900/60 p-3.5 rounded-xl border border-white/5 space-y-1">
            <span className="font-bold text-rose-400 block">2. Rumus Parkir Paralel Sempit</span>
            <p className="text-zinc-300 leading-relaxed">
              Sejajarkan spion dengan mobil sebelah (jarak 1 meter), putar setir habis ke arah trotoar, mundur sampai spion samping melihat plat mobil belakang di sudut 45 derajat.
            </p>
          </div>
        </div>
      </div>

      {/* Bantuan & FAQ */}
      <div className="glass-card rounded-2xl p-5 border border-white/10 space-y-3">
        <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <HelpCircle className="w-4 h-4 text-rose-400" />
          Pertanyaan Umum (FAQ)
        </h3>

        <div className="space-y-2">
          {faqs.map((faq, idx) => (
            <div
              key={idx}
              className="bg-zinc-900/50 rounded-xl border border-white/5 overflow-hidden transition"
            >
              <button
                onClick={() => setActiveFaq(activeFaq === idx ? null : idx)}
                className="w-full p-3.5 text-left text-xs font-semibold text-white flex items-center justify-between gap-2 cursor-pointer hover:text-rose-400 transition"
              >
                <span>{faq.q}</span>
                <ChevronRight
                  className={`w-4 h-4 shrink-0 transition-transform ${
                    activeFaq === idx ? 'rotate-90 text-rose-400' : 'text-zinc-500'
                  }`}
                />
              </button>
              {activeFaq === idx && (
                <div className="px-3.5 pb-3.5 text-xs text-zinc-300 border-t border-white/5 pt-2 leading-relaxed">
                  {faq.a}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Kontak Kantor LPK Indotech */}
      <div className="glass-card rounded-2xl p-5 border border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <Building2 className="w-4 h-4 text-rose-400" />
            <h4 className="text-xs font-bold text-white uppercase tracking-wider">
              Kantor Pusat LPK Indotech
            </h4>
          </div>
          <p className="text-xs text-zinc-300">
            Jl. Gerilya No. 88, Purwokerto Selatan, Kab. Banyumas (Buka Setiap Hari: 07:30 - 18:00)
          </p>
        </div>

        <button
          onClick={() => alert('Membuka WhatsApp Layanan Siswa LPK Indotech...')}
          className="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs flex items-center justify-center gap-2 transition cursor-pointer shrink-0"
        >
          <Phone className="w-3.5 h-3.5" />
          Chat Customer Service
        </button>
      </div>
    </div>
  );
}
