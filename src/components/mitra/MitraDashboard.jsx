import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Car, 
  MapPin, 
  CheckCircle2, 
  X, 
  Star, 
  Wallet, 
  Calendar, 
  Clock, 
  ShieldCheck, 
  Send, 
  AlertCircle,
  BellRing
} from 'lucide-react';
import confetti from 'canvas-confetti';

export default function MitraDashboard() {
  const [isOnline, setIsOnline] = useState(true);
  const [activeOrder, setActiveOrder] = useState({
    id: 'ORD-9821',
    studentName: 'Sarah Amelia (Mahasiswi Unsoed)',
    phone: '0857-1234-5678',
    pickupAddress: 'Jl. Kampus Grendeng No. 45, Purwokerto Utara',
    distanceKm: 2.1,
    transmission: 'Manual',
    date: 'Besok, 18 Nov 2026',
    slot: '09:00 - 11:00 WIB',
    mitraEarnings: 90000,
    status: 'pending' // pending, accepted, rejected
  });

  // Checklist penilaian siswa
  const [evalStudent, setEvalStudent] = useState({
    name: 'Dimas Aditya Pratama',
    module: 'Modul 3: Stop & Go Tanjakan Baturraden',
    score: 92,
    skills: {
      clutchControl: true,
      handbrakeTechnique: true,
      mirrorCheck: false,
      calmnessUnderPressure: true
    },
    notes: 'Feeling kopling sangat bagus saat stop-and-go di tanjakan. Spion kiri masih perlu lebih sering dipantau sebelum manuver jalan raya.'
  });

  const [evalSent, setEvalSent] = useState(false);

  const handleAcceptOrder = () => {
    setActiveOrder({ ...activeOrder, status: 'accepted' });
    confetti({
      particleCount: 50,
      spread: 50,
      origin: { y: 0.5 }
    });
  };

  const handleRejectOrder = () => {
    setActiveOrder({ ...activeOrder, status: 'rejected' });
  };

  const handleSendEvaluation = (e) => {
    e.preventDefault();
    setEvalSent(true);
    confetti({
      particleCount: 40,
      spread: 60,
      origin: { y: 0.7 }
    });
  };

  return (
    <div className="space-y-6 pb-28">
      {/* Header Profile Mitra */}
      <div className="glass-card rounded-3xl p-5 sm:p-6 border border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3.5">
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80"
            alt="Bambang Sugiantoro"
            className="w-14 h-14 rounded-2xl object-cover border-2 border-rose-500 shadow-md shrink-0"
          />
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base font-bold text-white">Bambang Sugiantoro</h2>
              <span className="text-[10px] bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2 py-0.5 rounded-full font-bold">
                Mitra Utama
              </span>
            </div>
            <p className="text-xs text-zinc-400 mt-0.5">
              Toyota Avanza (R 1842 BS) • <span className="text-emerald-400 font-semibold">Rem Ganda Terverifikasi LPK</span>
            </p>
            <div className="flex items-center gap-2 text-xs text-amber-400 mt-1">
              <Star className="w-3.5 h-3.5 fill-amber-400" />
              <span className="font-bold">4.9</span>
              <span className="text-zinc-500">| 142 Sesi Lulus</span>
            </div>
          </div>
        </div>

        {/* Toggle Status Online */}
        <div className="flex items-center gap-3 bg-zinc-900/80 p-2.5 rounded-2xl border border-white/10 self-start sm:self-auto">
          <div className="text-right text-xs">
            <span className="text-zinc-400 block text-[10px]">Status Operasional:</span>
            <span className={`font-bold ${isOnline ? 'text-emerald-400' : 'text-zinc-500'}`}>
              {isOnline ? 'Siaga Terima Order' : 'Offline / Istirahat'}
            </span>
          </div>
          <button
            onClick={() => setIsOnline(!isOnline)}
            className={`w-12 h-6 flex items-center rounded-full p-1 cursor-pointer transition-colors duration-300 ${
              isOnline ? 'bg-rose-500' : 'bg-zinc-700'
            }`}
          >
            <motion.div
              layout
              transition={{ type: 'spring', stiffness: 500, damping: 30 }}
              className={`bg-white w-4 h-4 rounded-full shadow-md transform ${
                isOnline ? 'translate-x-6' : 'translate-x-0'
              }`}
            />
          </button>
        </div>
      </div>

      {/* Wallet / Earning Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="glass-card rounded-2xl p-4 border border-white/10">
          <div className="flex items-center justify-between text-zinc-400 text-xs">
            <span>Saldo Dompet Mitra</span>
            <Wallet className="w-4 h-4 text-emerald-400" />
          </div>
          <div className="text-xl font-extrabold text-white mt-1">
            Rp 2.850.000
          </div>
          <span className="text-[10px] text-emerald-400 mt-1 block">
            Dapat ditarik ke rekening kapan saja
          </span>
        </div>

        <div className="glass-card rounded-2xl p-4 border border-white/10">
          <div className="flex items-center justify-between text-zinc-400 text-xs">
            <span>Sesi Bulan Ini</span>
            <Calendar className="w-4 h-4 text-rose-400" />
          </div>
          <div className="text-xl font-extrabold text-white mt-1">
            19 Sesi Latihan
          </div>
          <span className="text-[10px] text-zinc-400 mt-1 block">
            Target insentif: 25 sesi (sisa 6 sesi lagi)
          </span>
        </div>

        <div className="glass-card rounded-2xl p-4 border border-white/10">
          <div className="flex items-center justify-between text-zinc-400 text-xs">
            <span>Bagi Hasil Mitra</span>
            <Car className="w-4 h-4 text-blue-400" />
          </div>
          <div className="text-xl font-extrabold text-white mt-1">
            60% Otomatis
          </div>
          <span className="text-[10px] text-zinc-400 mt-1 block">
            Rp 90.000 / sesi 2 jam masuk otomatis
          </span>
        </div>
      </div>

      {/* Incoming Order Card (Real-time Simulation) */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <BellRing className="w-4 h-4 text-rose-500 animate-bounce" />
          <h3 className="text-sm font-bold text-white uppercase tracking-wider">
            Order Pelatihan Masuk (Radius 2.1 km)
          </h3>
        </div>

        {activeOrder.status === 'pending' && (
          <motion.div
            initial={{ opacity: 0, scale: 0.98 }}
            animate={{ opacity: 1, scale: 1 }}
            className="glass-card rounded-3xl p-5 border-2 border-rose-500/50 shadow-[0_0_30px_rgba(244,63,94,0.2)] bg-zinc-900/90"
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-white/10">
              <div>
                <span className="text-[10px] text-rose-400 font-bold uppercase tracking-wider block">
                  Permintaan Booking Baru
                </span>
                <h4 className="text-base font-bold text-white">{activeOrder.studentName}</h4>
                <p className="text-xs text-zinc-400 flex items-center gap-1 mt-0.5">
                  <MapPin className="w-3.5 h-3.5 text-rose-400 shrink-0" />
                  {activeOrder.pickupAddress} ({activeOrder.distanceKm} km dari posisimu)
                </p>
              </div>

              <div className="text-left sm:text-right">
                <span className="text-[10px] text-zinc-400 block">Penghasilan Sesi Ini:</span>
                <span className="text-lg font-extrabold text-emerald-400 font-mono">
                  + Rp {activeOrder.mitraEarnings.toLocaleString('id-ID')}
                </span>
              </div>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 py-3 text-xs">
              <div className="bg-zinc-950/60 p-2.5 rounded-xl border border-white/5">
                <span className="text-[10px] text-zinc-500 block">Jadwal:</span>
                <span className="font-semibold text-zinc-200">{activeOrder.date}</span>
              </div>
              <div className="bg-zinc-950/60 p-2.5 rounded-xl border border-white/5">
                <span className="text-[10px] text-zinc-500 block">Waktu Sesi:</span>
                <span className="font-semibold text-zinc-200">{activeOrder.slot}</span>
              </div>
              <div className="bg-zinc-950/60 p-2.5 rounded-xl border border-white/5 col-span-2 sm:col-span-1">
                <span className="text-[10px] text-zinc-500 block">Pilihan Mobil:</span>
                <span className="font-semibold text-rose-400">{activeOrder.transmission} (Avanza)</span>
              </div>
            </div>

            <div className="flex gap-2.5 pt-2">
              <button
                onClick={handleAcceptOrder}
                className="flex-1 py-3 rounded-xl bg-gradient-to-r from-emerald-600 to-emerald-500 hover:from-emerald-500 hover:to-emerald-400 text-white font-bold text-xs uppercase tracking-wider shadow-[0_0_20px_rgba(16,185,129,0.4)] transition cursor-pointer flex items-center justify-center gap-1.5"
              >
                <CheckCircle2 className="w-4 h-4" />
                Terima Order & Jadwalkan
              </button>
              <button
                onClick={handleRejectOrder}
                className="px-4 py-3 rounded-xl bg-zinc-800 hover:bg-zinc-700 text-zinc-300 font-semibold text-xs border border-white/10 transition cursor-pointer"
              >
                Tolak / Alihkan
              </button>
            </div>
          </motion.div>
        )}

        {activeOrder.status === 'accepted' && (
          <div className="bg-emerald-500/10 border border-emerald-500/30 rounded-2xl p-4 text-xs text-emerald-300 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0" />
              <span>Order diterima! Jadwal telah dicatat di kalendermu. Notifikasi penjemputan akan aktif H-1 jam.</span>
            </div>
            <button
              onClick={() => setActiveOrder({ ...activeOrder, status: 'pending' })}
              className="text-[10px] text-zinc-400 hover:text-white underline cursor-pointer"
            >
              Simulasi Order Lain
            </button>
          </div>
        )}

        {activeOrder.status === 'rejected' && (
          <div className="bg-zinc-900 border border-white/10 rounded-2xl p-4 text-xs text-zinc-400 flex items-center justify-between">
            <span>Order dialihkan ke mitra terdekat lainnya.</span>
            <button
              onClick={() => setActiveOrder({ ...activeOrder, status: 'pending' })}
              className="text-rose-400 underline cursor-pointer"
            >
              Reset Simulasi
            </button>
          </div>
        )}
      </div>

      {/* Input Penilaian & Checklist Rapor Siswa */}
      <div className="glass-card rounded-3xl p-5 sm:p-6 border border-white/10 space-y-4">
        <div>
          <span className="text-xs font-bold text-rose-400 uppercase tracking-wider">
            Evaluasi Sesi Latihan
          </span>
          <h3 className="text-base font-bold text-white mt-0.5">
            Input Penilaian & Checklist Rapor Siswa
          </h3>
          <p className="text-xs text-zinc-400">
            Penilaian instruktur akan langsung masuk ke rapor digital siswa dan diverifikasi oleh Admin LPK.
          </p>
        </div>

        {evalSent ? (
          <div className="bg-emerald-500/10 border border-emerald-500/30 rounded-2xl p-4 text-center space-y-2">
            <CheckCircle2 className="w-8 h-8 text-emerald-400 mx-auto" />
            <h4 className="text-sm font-bold text-white">Penilaian Berhasil Dikirim ke Siswa & LPK!</h4>
            <p className="text-xs text-zinc-300">
              Siswa {evalStudent.name} telah menerima rapor modul tanjakan dengan skor {evalStudent.score}/100.
            </p>
            <button
              onClick={() => setEvalSent(false)}
              className="text-xs text-rose-400 hover:underline pt-2 inline-block cursor-pointer"
            >
              Edit / Nilai Siswa Lain
            </button>
          </div>
        ) : (
          <form onSubmit={handleSendEvaluation} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
              <div className="bg-zinc-900/60 p-3 rounded-xl border border-white/5">
                <span className="text-zinc-400 block text-[10px]">Nama Siswa:</span>
                <span className="font-bold text-white text-sm">{evalStudent.name}</span>
              </div>
              <div className="bg-zinc-900/60 p-3 rounded-xl border border-white/5">
                <span className="text-zinc-400 block text-[10px]">Modul yang Diajarkan:</span>
                <span className="font-bold text-rose-400 text-xs">{evalStudent.module}</span>
              </div>
            </div>

            {/* Checklist Penguasaan Skill */}
            <div className="space-y-2 text-xs">
              <label className="font-semibold text-zinc-300 block">
                Checklist Keterampilan Lapangan:
              </label>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {[
                  { key: 'clutchControl', label: 'Penguasaan Titik Setengah Kopling' },
                  { key: 'handbrakeTechnique', label: 'Teknik Rem Tangan di Tanjakan Curam' },
                  { key: 'mirrorCheck', label: 'Kedisiplinan Cek Spion Sebelum Belok' },
                  { key: 'calmnessUnderPressure', label: 'Ketenangan & Tidak Panik Saat Mesin Mati' },
                ].map((item) => (
                  <label
                    key={item.key}
                    className={`flex items-center gap-2 p-2.5 rounded-xl border cursor-pointer transition ${
                      evalStudent.skills[item.key]
                        ? 'bg-emerald-500/10 border-emerald-500/30 text-zinc-200'
                        : 'bg-zinc-900 border-white/5 text-zinc-400'
                    }`}
                  >
                    <input
                      type="checkbox"
                      checked={evalStudent.skills[item.key]}
                      onChange={(e) =>
                        setEvalStudent({
                          ...evalStudent,
                          skills: { ...evalStudent.skills, [item.key]: e.target.checked }
                        })
                      }
                      className="accent-emerald-500 w-4 h-4 rounded"
                    />
                    <span className="text-xs">{item.label}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Skor Penguasaan */}
            <div className="space-y-1.5 text-xs">
              <div className="flex justify-between items-center">
                <label className="font-semibold text-zinc-300">Skor Kelulusan Sesi:</label>
                <span className="text-base font-extrabold text-emerald-400 font-mono">
                  {evalStudent.score} / 100
                </span>
              </div>
              <input
                type="range"
                min="60"
                max="100"
                value={evalStudent.score}
                onChange={(e) => setEvalStudent({ ...evalStudent, score: Number(e.target.value) })}
                className="w-full accent-rose-500 cursor-pointer"
              />
            </div>

            {/* Catatan Instruktur */}
            <div className="space-y-1 text-xs">
              <label className="font-semibold text-zinc-300 block">
                Catatan Evaluasi Lapangan untuk Siswa:
              </label>
              <textarea
                value={evalStudent.notes}
                onChange={(e) => setEvalStudent({ ...evalStudent, notes: e.target.value })}
                rows={3}
                className="w-full bg-zinc-900 border border-white/10 rounded-xl p-3 text-xs text-white placeholder-zinc-500 outline-none focus:border-rose-500"
              />
            </div>

            <button
              type="submit"
              className="w-full py-3 rounded-xl bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-500 hover:to-rose-400 text-white font-bold text-xs uppercase tracking-wider shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer flex items-center justify-center gap-2"
            >
              <Send className="w-4 h-4" />
              Simpan & Terbitkan Nilai ke Rapor Siswa
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
