import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Award, 
  CheckCircle2, 
  Clock, 
  Star, 
  ShieldCheck, 
  Download, 
  Printer, 
  QrCode, 
  Eye, 
  X, 
  FileText,
  Car
} from 'lucide-react';
import { CURRICULUM_MODULES } from '../../data/mockData';
import confetti from 'canvas-confetti';

export default function ProgresBelajar() {
  const [showCertificate, setShowCertificate] = useState(false);
  const studentName = 'Dimas Aditya Pratama';
  const certificateId = 'LPK-IND/SIM-A/2026/XI-0842';

  const completedCount = CURRICULUM_MODULES.filter(m => m.status === 'completed').length;
  const progressPercent = Math.round((completedCount / CURRICULUM_MODULES.length) * 100);

  const handleOpenCertificate = () => {
    setShowCertificate(true);
    confetti({
      particleCount: 70,
      spread: 70,
      origin: { y: 0.5 }
    });
  };

  return (
    <div className="space-y-6 pb-28">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <span className="text-xs bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2.5 py-0.5 rounded-full font-bold">
            Kurikulum Terstandar Kemnaker
          </span>
          <h1 className="text-xl sm:text-2xl font-extrabold text-white mt-1">
            Rapor & Progres Belajar Siswa
          </h1>
          <p className="text-xs text-zinc-400">
            Pantau penguasaan teknik mengemudi, penilaian objektif instruktur, dan klaim sertifikat resmi.
          </p>
        </div>

        <button
          onClick={handleOpenCertificate}
          className="self-start sm:self-auto px-4 py-2.5 rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-zinc-950 font-bold text-xs flex items-center gap-2 shadow-[0_0_20px_rgba(245,158,11,0.3)] transition cursor-pointer"
        >
          <Award className="w-4 h-4 text-zinc-950" />
          Lihat Preview Sertifikat Resmi
        </button>
      </div>

      {/* Overview Progress Card */}
      <div className="glass-card rounded-3xl p-5 sm:p-6 border border-white/10 relative overflow-hidden">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="space-y-1">
            <span className="text-xs text-zinc-400">Tingkat Kemahiran Mengemudi</span>
            <div className="flex items-baseline gap-2">
              <span className="text-3xl font-extrabold text-white">{progressPercent}%</span>
              <span className="text-xs font-semibold text-rose-400">
                ({completedCount} dari {CURRICULUM_MODULES.length} Modul Selesai)
              </span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="text-right text-xs">
              <span className="text-zinc-400 block">Rata-rata Nilai:</span>
              <span className="text-base font-bold text-emerald-400">92.5 / 100 (Sangat Baik)</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center text-emerald-400">
              <Star className="w-5 h-5 fill-emerald-400" />
            </div>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="w-full h-3 bg-zinc-900 rounded-full mt-4 overflow-hidden border border-white/5">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progressPercent}%` }}
            transition={{ duration: 1, ease: 'easeOut' }}
            className="h-full bg-gradient-to-r from-rose-600 via-rose-500 to-amber-400 rounded-full shadow-[0_0_15px_rgba(244,63,94,0.7)]"
          />
        </div>
      </div>

      {/* Curriculum Modules List */}
      <div className="space-y-3">
        <h2 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <FileText className="w-4 h-4 text-rose-400" />
          Rincian Modul Pelatihan Lapangan
        </h2>

        <div className="space-y-3">
          {CURRICULUM_MODULES.map((mod) => (
            <div
              key={mod.id}
              className={`glass-card rounded-2xl p-4 sm:p-5 border transition ${
                mod.status === 'completed'
                  ? 'border-emerald-500/30 bg-zinc-900/40'
                  : mod.status === 'in_progress'
                  ? 'border-rose-500/50 bg-zinc-900/80 shadow-[0_0_20px_rgba(244,63,94,0.1)]'
                  : 'border-white/5 opacity-70'
              }`}
            >
              <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-3">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    {mod.status === 'completed' && (
                      <span className="flex items-center gap-1 text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2 py-0.5 rounded-full font-bold">
                        <CheckCircle2 className="w-3 h-3" /> Lulus
                      </span>
                    )}
                    {mod.status === 'in_progress' && (
                      <span className="flex items-center gap-1 text-[10px] bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2 py-0.5 rounded-full font-bold animate-pulse">
                        <Clock className="w-3 h-3" /> Sedang Dijalankan
                      </span>
                    )}
                    {mod.status === 'upcoming' && (
                      <span className="text-[10px] bg-zinc-800 text-zinc-400 px-2 py-0.5 rounded-full font-medium">
                        Menunggu Sesi
                      </span>
                    )}
                    <span className="text-xs text-zinc-500 font-mono">{mod.date}</span>
                  </div>

                  <h3 className="text-sm sm:text-base font-bold text-white pt-1">
                    {mod.title}
                  </h3>
                  <p className="text-xs text-zinc-300 max-w-xl">
                    {mod.description}
                  </p>
                </div>

                {mod.score !== null && (
                  <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-start gap-1 shrink-0 bg-zinc-900/60 p-2.5 rounded-xl border border-white/5">
                    <span className="text-[10px] text-zinc-400">Skor Penguasaan:</span>
                    <span className="text-lg font-extrabold text-emerald-400 font-mono">
                      {mod.score}/100
                    </span>
                  </div>
                )}
              </div>

              {/* Catatan Evaluasi Instruktur */}
              {mod.instructorNotes && (
                <div className="mt-3 pt-3 border-t border-white/5 text-xs text-zinc-400 bg-zinc-950/40 p-2.5 rounded-xl">
                  <span className="font-semibold text-rose-400 block mb-0.5">Catatan Instruktur Lapangan:</span>
                  <p className="text-zinc-300 italic">"{mod.instructorNotes}"</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Official Certificate Modal */}
      <AnimatePresence>
        {showCertificate && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md overflow-y-auto">
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="relative w-full max-w-2xl bg-zinc-950 border-2 border-amber-500/40 rounded-3xl p-6 sm:p-8 shadow-[0_0_50px_rgba(245,158,11,0.2)] my-8"
            >
              <button
                onClick={() => setShowCertificate(false)}
                className="absolute top-4 right-4 w-8 h-8 rounded-full bg-zinc-900 border border-white/10 flex items-center justify-center text-zinc-400 hover:text-white transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>

              {/* Certificate Canvas / Layout */}
              <div className="border border-amber-500/30 rounded-2xl p-6 bg-gradient-to-b from-zinc-900/90 to-zinc-950 space-y-6 text-center relative overflow-hidden">
                {/* Watermark Logo */}
                <div className="absolute inset-0 flex items-center justify-center opacity-5 pointer-events-none">
                  <Car className="w-80 h-80 text-amber-500" />
                </div>

                <div className="space-y-1">
                  <span className="text-xs font-mono tracking-widest text-amber-400 uppercase font-bold">
                    LEMBAGA PELATIHAN KERJA (LPK) INDOTECH
                  </span>
                  <h2 className="text-lg sm:text-2xl font-serif font-bold text-white tracking-wide uppercase">
                    Sertifikat Kelulusan Pengemudi
                  </h2>
                  <p className="text-[11px] font-mono text-zinc-400">
                    No. Sertifikat: <span className="text-amber-300">{certificateId}</span> • Terakreditasi Kemnaker RI
                  </p>
                </div>

                <div className="space-y-1 py-2">
                  <p className="text-xs text-zinc-400 italic">Diberikan secara sah kepada:</p>
                  <h3 className="text-xl sm:text-2xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-amber-300 via-yellow-100 to-amber-400 tracking-wider">
                    {studentName}
                  </h3>
                  <p className="text-xs text-zinc-300 max-w-md mx-auto pt-1 leading-relaxed">
                    Telah menyelesaikan program pelatihan mengemudi roda 4 kurikulum standar internasional, menguasai kontrol kendaraan, rambu lalu lintas jalan raya, dan siap uji kompetensi SIM A.
                  </p>
                </div>

                <div className="grid grid-cols-3 gap-2 border-t border-b border-amber-500/20 py-3 text-xs">
                  <div>
                    <span className="text-[10px] text-zinc-500 block">Kualifikasi:</span>
                    <span className="font-bold text-zinc-200">SIM A Standar</span>
                  </div>
                  <div>
                    <span className="text-[10px] text-zinc-500 block">Predikat:</span>
                    <span className="font-bold text-emerald-400">Sangat Mahir (A)</span>
                  </div>
                  <div>
                    <span className="text-[10px] text-zinc-500 block">Masa Berlaku:</span>
                    <span className="font-bold text-zinc-200">Seumur Hidup</span>
                  </div>
                </div>

                {/* Signatures & Barcode */}
                <div className="flex items-center justify-between pt-2 px-4 text-xs">
                  <div className="text-left space-y-1">
                    <span className="text-[10px] text-zinc-500 block">Instruktur Lapangan</span>
                    <div className="w-24 h-8 border-b border-zinc-700 flex items-center justify-center font-mono text-[10px] text-zinc-400 italic">
                      [Ttd Digital]
                    </div>
                    <span className="font-bold text-zinc-300 text-[11px]">Bambang Sugiantoro</span>
                  </div>

                  <div className="flex flex-col items-center">
                    <div className="p-2 bg-white rounded-lg">
                      <QrCode className="w-12 h-12 text-zinc-950" />
                    </div>
                    <span className="text-[9px] text-zinc-500 mt-1 font-mono">Verifikasi Online LPK</span>
                  </div>

                  <div className="text-right space-y-1">
                    <span className="text-[10px] text-zinc-500 block">Direktur LPK Indotech</span>
                    <div className="w-24 h-8 border-b border-zinc-700 flex items-center justify-center font-mono text-[10px] text-zinc-400 italic">
                      [Stempel Resmi]
                    </div>
                    <span className="font-bold text-amber-400 text-[11px]">Drs. H. M. Indotech</span>
                  </div>
                </div>
              </div>

              {/* Modal Actions */}
              <div className="flex gap-3 mt-4">
                <button
                  onClick={() => alert('Sertifikat resmi siap diunduh dalam format PDF ber-barcode!')}
                  className="flex-1 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-zinc-950 font-bold text-xs flex items-center justify-center gap-2 transition cursor-pointer"
                >
                  <Download className="w-4 h-4" />
                  Unduh E-Sertifikat (PDF)
                </button>
                <button
                  onClick={() => window.print()}
                  className="px-4 py-2.5 rounded-xl bg-zinc-900 hover:bg-zinc-800 text-zinc-200 border border-white/10 text-xs font-semibold flex items-center justify-center gap-2 transition cursor-pointer"
                >
                  <Printer className="w-4 h-4" />
                  Cetak
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
