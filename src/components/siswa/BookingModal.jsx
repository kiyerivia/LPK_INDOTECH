import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  X, 
  Calendar as CalendarIcon, 
  Clock, 
  MapPin, 
  ShieldCheck, 
  CreditCard, 
  CheckCircle2, 
  Car, 
  QrCode, 
  Sparkles,
  ArrowRight
} from 'lucide-react';
import confetti from 'canvas-confetti';

export default function BookingModal({ instructor, selectedPackage, isOpen, onClose, onBookingSuccess }) {
  const [selectedDate, setSelectedDate] = useState('Besok, 18 Nov 2026');
  const [selectedSlot, setSelectedSlot] = useState(instructor?.availableSlots[0] || '08:00 - 10:00');
  const [pickupAddress, setPickupAddress] = useState('Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara');
  const [transmission, setTransmission] = useState('Manual');
  const [paymentMethod, setPaymentMethod] = useState('qris');
  const [isProcessing, setIsProcessing] = useState(false);
  const [isPaid, setIsPaid] = useState(false);

  if (!isOpen || !instructor) return null;

  const sessionCost = selectedPackage ? selectedPackage.price : 150000;
  // Calculate split as outlined in the pitch
  const instructorFee = Math.round(sessionCost * 0.60);
  const lpkFee = Math.round(sessionCost * 0.27);
  const platformFee = sessionCost - instructorFee - lpkFee;

  const handlePay = () => {
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      setIsPaid(true);
      confetti({
        particleCount: 80,
        spread: 60,
        origin: { y: 0.6 }
      });
      if (onBookingSuccess) {
        onBookingSuccess({
          instructor,
          date: selectedDate,
          slot: selectedSlot,
          address: pickupAddress,
          cost: sessionCost
        });
      }
    }, 1500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md overflow-y-auto">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="relative w-full max-w-lg glass-card rounded-3xl p-5 sm:p-6 border border-white/10 shadow-2xl overflow-hidden my-8"
      >
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 w-8 h-8 rounded-full bg-zinc-900 border border-white/10 flex items-center justify-center text-zinc-400 hover:text-white transition cursor-pointer"
        >
          <X className="w-4 h-4" />
        </button>

        {isPaid ? (
          /* Payment Success State */
          <div className="py-6 text-center space-y-4">
            <div className="w-16 h-16 rounded-full bg-emerald-500/20 border-2 border-emerald-400 text-emerald-400 flex items-center justify-center mx-auto shadow-[0_0_30px_rgba(16,185,129,0.4)] animate-bounce">
              <CheckCircle2 className="w-8 h-8" />
            </div>

            <h3 className="text-xl font-bold text-white">Jadwal Berhasil Dikunci!</h3>
            <p className="text-xs sm:text-sm text-zinc-300 max-w-sm mx-auto">
              Instruktur <strong className="text-rose-400">{instructor.name}</strong> akan datang menjemput ke alamatmu sesuai jadwal.
            </p>

            <div className="bg-zinc-900/80 rounded-2xl p-4 border border-white/10 text-left text-xs space-y-2">
              <div className="flex justify-between">
                <span className="text-zinc-400">Jadwal Latihan:</span>
                <span className="font-semibold text-white">{selectedDate} ({selectedSlot})</span>
              </div>
              <div className="flex justify-between">
                <span className="text-zinc-400">Mobil Latihan:</span>
                <span className="font-semibold text-white">{instructor.carModel} ({transmission})</span>
              </div>
              <div className="flex justify-between">
                <span className="text-zinc-400">Titik Jemput:</span>
                <span className="font-semibold text-zinc-300 truncate max-w-[200px]">{pickupAddress}</span>
              </div>
              <div className="flex justify-between border-t border-white/10 pt-2 text-rose-400 font-bold">
                <span>Total Terbayar:</span>
                <span>Rp {sessionCost.toLocaleString('id-ID')} (LUNAS)</span>
              </div>
            </div>

            <button
              onClick={onClose}
              className="w-full py-3 rounded-xl bg-rose-500 hover:bg-rose-600 text-white font-bold text-xs uppercase tracking-wider shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer"
            >
              Kembali ke Menu Utama
            </button>
          </div>
        ) : (
          /* Booking Form */
          <div className="space-y-4">
            <div>
              <span className="text-[10px] text-rose-400 font-bold uppercase tracking-wider">
                Booking Jadwal & Penjemputan
              </span>
              <h2 className="text-lg font-bold text-white mt-0.5">
                Konfirmasi Sesi Latihan Mengemudi
              </h2>
            </div>

            {/* Selected Instructor Snapshot */}
            <div className="flex items-center gap-3 bg-zinc-900/60 p-3 rounded-2xl border border-white/5">
              <img
                src={instructor.avatar}
                alt={instructor.name}
                className="w-12 h-12 rounded-xl object-cover border border-rose-500/40"
              />
              <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between">
                  <h4 className="text-xs font-bold text-white truncate">{instructor.name}</h4>
                  <span className="text-[10px] text-rose-400 font-bold">{instructor.distanceKm} km</span>
                </div>
                <p className="text-[11px] text-zinc-400">{instructor.carModel}</p>
                <div className="flex items-center gap-1 text-[10px] text-emerald-400 mt-0.5">
                  <ShieldCheck className="w-3 h-3" />
                  <span>{instructor.dualPedal}</span>
                </div>
              </div>
            </div>

            {/* Pilih Tanggal & Slot */}
            <div className="space-y-2">
              <label className="text-xs font-semibold text-zinc-300 flex items-center gap-1.5">
                <CalendarIcon className="w-3.5 h-3.5 text-rose-400" /> Pilih Hari:
              </label>
              <div className="grid grid-cols-3 gap-2 text-xs">
                {['Hari Ini, 17 Nov', 'Besok, 18 Nov', 'Lusa, 19 Nov'].map((d) => (
                  <button
                    key={d}
                    type="button"
                    onClick={() => setSelectedDate(d)}
                    className={`py-2 px-1 rounded-xl border text-center transition cursor-pointer text-[11px] ${
                      selectedDate === d
                        ? 'bg-rose-500/20 border-rose-500 text-rose-300 font-bold shadow-sm'
                        : 'bg-zinc-900 border-white/5 text-zinc-400 hover:text-white'
                    }`}
                  >
                    {d}
                  </button>
                ))}
              </div>
            </div>

            {/* Pilih Slot Waktu */}
            <div className="space-y-2">
              <div className="flex justify-between items-center text-xs">
                <label className="font-semibold text-zinc-300 flex items-center gap-1.5">
                  <Clock className="w-3.5 h-3.5 text-rose-400" /> Slot Waktu Tersedia:
                </label>
                <span className="text-[10px] text-zinc-400">Jeda buffer 30m aman</span>
              </div>
              <div className="grid grid-cols-2 gap-2 text-xs">
                {instructor.availableSlots.map((slot) => (
                  <button
                    key={slot}
                    type="button"
                    onClick={() => setSelectedSlot(slot)}
                    className={`py-2 px-2 rounded-xl border text-center transition cursor-pointer text-[11px] ${
                      selectedSlot === slot
                        ? 'bg-rose-500 border-rose-500 text-white font-bold shadow-[0_0_12px_rgba(244,63,94,0.4)]'
                        : 'bg-zinc-900 border-white/5 text-zinc-300 hover:text-white'
                    }`}
                  >
                    {slot}
                  </button>
                ))}
              </div>
            </div>

            {/* Input Alamat Jemput */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-zinc-300 flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-rose-400" /> Titik Penjemputan (Door to Door):
              </label>
              <input
                type="text"
                value={pickupAddress}
                onChange={(e) => setPickupAddress(e.target.value)}
                className="w-full bg-zinc-900 border border-white/10 rounded-xl px-3 py-2 text-xs text-white placeholder-zinc-500 outline-none focus:border-rose-500"
              />
            </div>

            {/* Transmisi */}
            <div className="flex items-center justify-between text-xs bg-zinc-900/50 p-2.5 rounded-xl border border-white/5">
              <span className="text-zinc-300 flex items-center gap-1.5">
                <Car className="w-3.5 h-3.5 text-zinc-400" /> Transmisi Mobil:
              </span>
              <div className="flex gap-2">
                {['Manual', 'Matic'].map((t) => (
                  <button
                    key={t}
                    type="button"
                    onClick={() => setTransmission(t)}
                    className={`px-3 py-1 rounded-lg text-xs font-semibold transition cursor-pointer ${
                      transmission === t
                        ? 'bg-rose-500 text-white'
                        : 'bg-zinc-800 text-zinc-400 hover:text-white'
                    }`}
                  >
                    {t}
                  </button>
                ))}
              </div>
            </div>

            {/* Transparansi Sistem Bagi Hasil (Paling Menarik dari Pitch!) */}
            <div className="bg-zinc-900/90 rounded-2xl p-3 border border-white/10 text-xs space-y-1.5">
              <div className="flex justify-between items-center text-zinc-400 text-[11px]">
                <span>Alokasi Mitra Instruktur (60%):</span>
                <span className="text-zinc-200 font-mono">Rp {instructorFee.toLocaleString('id-ID')}</span>
              </div>
              <div className="flex justify-between items-center text-zinc-400 text-[11px]">
                <span>Alokasi LPK Indotech (27%):</span>
                <span className="text-zinc-200 font-mono">Rp {lpkFee.toLocaleString('id-ID')}</span>
              </div>
              <div className="flex justify-between items-center text-zinc-400 text-[11px]">
                <span>Platform & Asuransi Keamanan (13%):</span>
                <span className="text-zinc-200 font-mono">Rp {platformFee.toLocaleString('id-ID')}</span>
              </div>
              <div className="flex justify-between items-center text-white font-bold border-t border-white/10 pt-1.5 text-sm">
                <span>Total Investasi Pelatihan:</span>
                <span className="text-rose-400 font-mono">Rp {sessionCost.toLocaleString('id-ID')}</span>
              </div>
            </div>

            {/* Metode Pembayaran */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-zinc-300 flex items-center gap-1.5">
                <CreditCard className="w-3.5 h-3.5 text-rose-400" /> Metode Pembayaran Cepat:
              </label>
              <div className="grid grid-cols-3 gap-2">
                {[
                  { id: 'qris', name: 'QRIS Auto', icon: QrCode },
                  { id: 'bca', name: 'BCA VA', icon: CreditCard },
                  { id: 'gopay', name: 'GoPay / OVO', icon: Sparkles },
                ].map((m) => {
                  const Icon = m.icon;
                  return (
                    <button
                      key={m.id}
                      type="button"
                      onClick={() => setPaymentMethod(m.id)}
                      className={`p-2 rounded-xl border flex flex-col items-center justify-center gap-1 transition cursor-pointer text-xs ${
                        paymentMethod === m.id
                          ? 'bg-rose-500/20 border-rose-500 text-rose-300 font-bold'
                          : 'bg-zinc-900 border-white/5 text-zinc-400 hover:text-white'
                      }`}
                    >
                      <Icon className="w-4 h-4 text-rose-400" />
                      <span className="text-[10px]">{m.name}</span>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Tombol Eksekusi Bayar */}
            <button
              onClick={handlePay}
              disabled={isProcessing}
              className="w-full py-3 rounded-xl bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-500 hover:to-rose-400 text-white font-bold text-xs uppercase tracking-wider shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {isProcessing ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  Memverifikasi Pembayaran...
                </>
              ) : (
                <>
                  Kunci Jadwal & Bayar Sekarang
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </div>
        )}
      </motion.div>
    </div>
  );
}
