import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  Building2, 
  Users, 
  Car, 
  DollarSign, 
  CheckCircle2, 
  Clock, 
  FileText, 
  ShieldCheck, 
  Award, 
  MapPin, 
  TrendingUp, 
  Download,
  AlertTriangle
} from 'lucide-react';
import confetti from 'canvas-confetti';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('overview'); // overview, mitra, siswa, sertifikat

  // Mock Mitra Pending Verification
  const [pendingMitra, setPendingMitra] = useState([
    {
      id: 'MIT-008',
      name: 'Rudi Hartono (Eks Driver Maxim/GoCar)',
      phone: '0813-8822-1100',
      simType: 'SIM A Umum & SIM B1',
      car: 'Toyota Calya G (2022) - R 4019 TR',
      dualPedalProof: 'Braket Rem Ganda Lulus Uji LPK',
      skck: 'Terlampir & Aktif',
      status: 'pending'
    }
  ]);

  const [graduations, setGraduations] = useState([
    {
      id: 'GRD-102',
      studentName: 'Dimas Aditya Pratama',
      instructor: 'Bambang Sugiantoro',
      avgScore: 92.5,
      simStatus: 'Siap Tes Satpas Banyumas',
      purpose: 'Persiapan Ujian SIM A & Mobil Harian',
      certStatus: 'Approved'
    },
    {
      id: 'GRD-103',
      studentName: 'Nadia Safitri',
      instructor: 'Dewi Anggraeni, S.Pd',
      avgScore: 95.0,
      simStatus: 'SIM A Terbit',
      purpose: 'Mobil Keluarga / Perjalanan Kerja',
      certStatus: 'Pending Approval'
    }
  ]);

  const handleApproveMitra = (id) => {
    setPendingMitra(pendingMitra.map(m => m.id === id ? { ...m, status: 'approved' } : m));
    confetti({ particleCount: 40, spread: 50, origin: { y: 0.5 } });
  };

  const handleApproveCert = (id) => {
    setGraduations(graduations.map(g => g.id === id ? { ...g, certStatus: 'Approved' } : g));
    confetti({ particleCount: 50, spread: 60, origin: { y: 0.5 } });
  };

  return (
    <div className="space-y-6 pb-28">
      {/* Admin Header */}
      <div className="glass-card rounded-3xl p-5 sm:p-6 border border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl sm:text-2xl font-extrabold text-white">
              Pusat Kendali Admin LPK Indotech
            </h1>
            <span className="text-xs bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2 py-0.5 rounded-full font-bold">
              HQ Purwokerto
            </span>
          </div>
          <p className="text-xs text-zinc-400 mt-1">
            Monitoring omzet kursus mengemudi, verifikasi mitra instruktur lapangan, kontrol kurikulum, dan otorisasi sertifikasi resmi.
          </p>
        </div>

        {/* Tab pills */}
        <div className="flex items-center gap-1.5 bg-zinc-900/90 p-1 rounded-2xl border border-white/10 text-xs self-start sm:self-auto">
          {[
            { id: 'overview', label: 'Ringkasan' },
            { id: 'mitra', label: 'Verifikasi Mitra' },
            { id: 'sertifikat', label: 'Kelulusan & Sertifikat' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-3 py-1.5 rounded-xl font-medium transition cursor-pointer text-xs ${
                activeTab === tab.id
                  ? 'bg-rose-500 text-white shadow-[0_0_12px_rgba(244,63,94,0.4)]'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Overview Stats */}
      {activeTab === 'overview' && (
        <div className="space-y-6">
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            <div className="glass-card rounded-2xl p-4 border border-white/10">
              <span className="text-[11px] text-zinc-400 block">Total Omzet Bulan Ini</span>
              <div className="text-xl font-extrabold text-white mt-1">Rp 48.600.000</div>
              <span className="text-[10px] text-emerald-400 font-semibold flex items-center gap-1 mt-1">
                <TrendingUp className="w-3 h-3" /> +18.4% dari bulan lalu
              </span>
            </div>

            <div className="glass-card rounded-2xl p-4 border border-white/10">
              <span className="text-[11px] text-zinc-400 block">Bagian LPK (27%)</span>
              <div className="text-xl font-extrabold text-rose-400 mt-1">Rp 13.122.000</div>
              <span className="text-[10px] text-zinc-400 mt-1 block">Kas Operasional LPK</span>
            </div>

            <div className="glass-card rounded-2xl p-4 border border-white/10">
              <span className="text-[11px] text-zinc-400 block">Mitra Instruktur Aktif</span>
              <div className="text-xl font-extrabold text-white mt-1">28 Driver</div>
              <span className="text-[10px] text-zinc-400 mt-1 block">Tersertifikasi TOT Rem Ganda</span>
            </div>

            <div className="glass-card rounded-2xl p-4 border border-white/10">
              <span className="text-[11px] text-zinc-400 block">Siswa Aktif Pelatihan</span>
              <div className="text-xl font-extrabold text-white mt-1">64 Siswa</div>
              <span className="text-[10px] text-zinc-400 mt-1 block">12 Siswa siap ujian SIM</span>
            </div>
          </div>

          {/* Model Bisnis Breakdown Card */}
          <div className="glass-card rounded-3xl p-5 sm:p-6 border border-white/10 space-y-4">
            <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
              <DollarSign className="w-4 h-4 text-rose-400" />
              Formula Distribusi Bagi Hasil Otomatis (Smart Split)
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              <div className="bg-zinc-900/60 p-4 rounded-2xl border border-white/5 space-y-1">
                <span className="text-xs text-zinc-400 font-medium">1. Mitra Instruktur Lapangan</span>
                <div className="text-2xl font-extrabold text-emerald-400">60%</div>
                <p className="text-xs text-zinc-400 leading-relaxed">
                  Meng-cover jasa mengajar, bahan bakar (BBM), perawatan kendaraan, dan insentif keselamatan.
                </p>
              </div>

              <div className="bg-zinc-900/60 p-4 rounded-2xl border border-white/5 space-y-1">
                <span className="text-xs text-zinc-400 font-medium">2. LPK Indotech (Pusat Kurikulum)</span>
                <div className="text-2xl font-extrabold text-rose-400">27%</div>
                <p className="text-xs text-zinc-400 leading-relaxed">
                  Penerbitan sertifikat resmi, akreditasi Kemnaker, dan pendampingan resmi ujian SIM A di Satpas.
                </p>
              </div>

              <div className="bg-zinc-900/60 p-4 rounded-2xl border border-white/5 space-y-1">
                <span className="text-xs text-zinc-400 font-medium">3. Platform & Asuransi Keamanan</span>
                <div className="text-2xl font-extrabold text-blue-400">13%</div>
                <p className="text-xs text-zinc-400 leading-relaxed">
                  Biaya server, sistem pencarian instruktur terdekat, customer support, dan premi proteksi asuransi latihan.
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tab: Verifikasi Mitra Driver */}
      {activeTab === 'mitra' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-bold text-white uppercase tracking-wider">
                Pengajuan Mitra Instruktur Baru (KYC & Safety Check)
              </h3>
              <p className="text-xs text-zinc-400">
                Setiap calon mitra wajib lolos uji rem ganda & pelatihan pengajaran (TOT) sebelum dapat menerima order.
              </p>
            </div>
          </div>

          <div className="space-y-3">
            {pendingMitra.map((mitra) => (
              <div
                key={mitra.id}
                className="glass-card rounded-2xl p-5 border border-white/10 space-y-3"
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                  <div>
                    <span className="text-[10px] text-zinc-500 font-mono">{mitra.id}</span>
                    <h4 className="text-base font-bold text-white">{mitra.name}</h4>
                    <p className="text-xs text-zinc-400">Telp: {mitra.phone}</p>
                  </div>
                  <span className={`text-xs px-2.5 py-1 rounded-full font-bold self-start sm:self-auto ${
                    mitra.status === 'approved'
                      ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                      : 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                  }`}>
                    {mitra.status === 'approved' ? 'Terverifikasi Aktif' : 'Menunggu Approval Safety'}
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 text-xs bg-zinc-950/60 p-3 rounded-xl border border-white/5">
                  <div>
                    <span className="text-[10px] text-zinc-500 block">Lisensi / SIM:</span>
                    <span className="font-semibold text-zinc-200">{mitra.simType}</span>
                  </div>
                  <div>
                    <span className="text-[10px] text-zinc-500 block">Unit Mobil:</span>
                    <span className="font-semibold text-zinc-200">{mitra.car}</span>
                  </div>
                  <div>
                    <span className="text-[10px] text-zinc-500 block">Proteksi Pedal Rem:</span>
                    <span className="font-semibold text-emerald-400 flex items-center gap-1">
                      <ShieldCheck className="w-3.5 h-3.5" />
                      {mitra.dualPedalProof}
                    </span>
                  </div>
                </div>

                {mitra.status === 'pending' ? (
                  <div className="flex gap-2.5 pt-1">
                    <button
                      onClick={() => handleApproveMitra(mitra.id)}
                      className="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs flex items-center gap-1.5 transition cursor-pointer"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      Setujui & Terbitkan Lisensi Instruktur LPK
                    </button>
                    <button className="px-4 py-2 rounded-xl bg-zinc-800 hover:bg-zinc-700 text-zinc-300 text-xs transition cursor-pointer">
                      Minta Uji Lapangan Ulang
                    </button>
                  </div>
                ) : (
                  <div className="text-xs text-emerald-400 flex items-center gap-1.5 font-medium">
                    <CheckCircle2 className="w-4 h-4" />
                    Mitra telah resmi aktif dan masuk ke algoritma pencarian terdekat siswa.
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab: Kelulusan & Sertifikat Siswa */}
      {activeTab === 'sertifikat' && (
        <div className="space-y-4">
          <div>
            <h3 className="text-sm font-bold text-white uppercase tracking-wider">
              Daftar Kelulusan & Otorisasi Sertifikat Resmi LPK
            </h3>
            <p className="text-xs text-zinc-400">
              Sertifikat yang disetujui akan otomatis mendapat nomor registrasi Kemnaker dan QR Code verifikasi.
            </p>
          </div>

          <div className="space-y-3">
            {graduations.map((g) => (
              <div
                key={g.id}
                className="glass-card rounded-2xl p-4 sm:p-5 border border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-4"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h4 className="text-sm sm:text-base font-bold text-white">{g.studentName}</h4>
                    <span className="text-[10px] bg-zinc-800 text-zinc-300 px-2 py-0.5 rounded-full font-mono">
                      Skor {g.avgScore}/100
                    </span>
                  </div>
                  <p className="text-xs text-zinc-400">
                    Instruktur: <span className="text-zinc-200">{g.instructor}</span> • Status: <span className="text-emerald-400">{g.simStatus}</span>
                  </p>
                  <p className="text-xs text-rose-400 font-medium">
                    Tujuan: {g.purpose}
                  </p>
                </div>

                <div className="flex items-center gap-2.5">
                  {g.certStatus === 'Approved' ? (
                    <span className="text-xs bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-3 py-1.5 rounded-xl font-bold flex items-center gap-1.5">
                      <Award className="w-4 h-4" /> Sertifikat Aktif
                    </span>
                  ) : (
                    <button
                      onClick={() => handleApproveCert(g.id)}
                      className="px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-zinc-950 font-bold text-xs flex items-center gap-1.5 shadow-[0_0_15px_rgba(245,158,11,0.3)] transition cursor-pointer"
                    >
                      <Award className="w-4 h-4" />
                      Otorisasi Sertifikat
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
