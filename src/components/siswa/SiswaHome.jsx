import React from 'react';
import { motion } from 'framer-motion';
import { 
  Compass, 
  ShieldCheck, 
  Star, 
  Clock, 
  MapPin, 
  ChevronRight, 
  Award, 
  Car, 
  Sparkles,
  Calendar,
  CheckCircle2
} from 'lucide-react';
import { INSTRUCTORS, PACKAGES, CURRICULUM_MODULES } from '../../data/mockData';

export default function SiswaHome({ onNavigate, onSelectPackage, onSelectInstructor }) {
  const activeInstructor = INSTRUCTORS[0]; // Bambang Sugiantoro

  return (
    <div className="space-y-6 pb-28">
      {/* Hero Glass Banner */}
      <motion.div
        initial={{ opacity: 0, y: 15 }}
        animate={{ opacity: 1, y: 0 }}
        className="relative overflow-hidden rounded-3xl glass-card p-5 sm:p-7 border border-white/10"
      >
        {/* Ambient background glow inside card */}
        <div className="absolute -top-16 -right-16 w-48 h-48 bg-rose-500/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-16 -left-16 w-48 h-48 bg-blue-500/15 rounded-full blur-3xl pointer-events-none" />

        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="space-y-2 max-w-lg">
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-rose-500/15 border border-rose-500/30 text-rose-300 text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5 text-rose-400" />
              Kursus Mengemudi Terstandar & Jemput di Rumah
            </div>
            <h1 className="text-xl sm:text-2xl font-extrabold text-white tracking-tight leading-snug">
              Belajar Nyetir Bersama <span className="text-transparent bg-clip-text bg-gradient-to-r from-rose-400 to-rose-600">Instruktur Terdekat</span>
            </h1>
            <p className="text-xs sm:text-sm text-zinc-300 leading-relaxed">
              LPK Indotech menghadirkan pelatihan setir mobil profesional dengan mitra instruktur berpengalaman, mobil ber-rem ganda, kurikulum resmi, serta pendampingan ujian SIM A sampai lulus.
            </p>
          </div>

          <div className="flex flex-col sm:flex-row gap-2.5 shrink-0">
            <button
              onClick={() => onNavigate('search')}
              className="px-4 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-500 hover:to-rose-400 text-white text-xs sm:text-sm font-semibold flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer"
            >
              <Compass className="w-4 h-4" />
              Cari Instruktur Terdekat
            </button>
            <button
              onClick={() => onNavigate('schedule')}
              className="px-4 py-2.5 rounded-xl bg-zinc-900/80 hover:bg-zinc-800 text-zinc-200 border border-white/10 text-xs sm:text-sm font-medium flex items-center justify-center gap-2 transition cursor-pointer"
            >
              <Calendar className="w-4 h-4 text-rose-400" />
              Jadwal Sesi Saya
            </button>
          </div>
        </div>
      </motion.div>

      {/* Radar Live Preview Widget */}
      <div className="glass-card rounded-2xl p-4 sm:p-5 border border-white/10">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping" />
            <h2 className="text-sm font-bold text-white tracking-wide">
              RADAR INSTRUKTUR AKTIF
            </h2>
            <span className="text-[10px] text-zinc-400 bg-zinc-800/80 px-2 py-0.5 rounded-full border border-white/5">
              Radius 1.8 - 4.1 km
            </span>
          </div>
          <button
            onClick={() => onNavigate('search')}
            className="text-xs text-rose-400 hover:text-rose-300 font-medium flex items-center gap-1 cursor-pointer"
          >
            Lihat Semua ({INSTRUCTORS.length}) <ChevronRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {INSTRUCTORS.map((inst) => (
            <div
              key={inst.id}
              onClick={() => {
                onSelectInstructor(inst);
                onNavigate('search');
              }}
              className="group glass-card glass-card-hover rounded-xl p-3 border border-white/5 cursor-pointer relative overflow-hidden"
            >
              <div className="flex items-center gap-3">
                <img
                  src={inst.avatar}
                  alt={inst.name}
                  className="w-12 h-12 rounded-xl object-cover border border-rose-500/30 shrink-0"
                />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-1">
                    <h3 className="text-xs font-bold text-white truncate group-hover:text-rose-400 transition">
                      {inst.name}
                    </h3>
                  </div>
                  <div className="flex items-center gap-1 text-[11px] text-amber-400 mt-0.5">
                    <Star className="w-3 h-3 fill-amber-400" />
                    <span>{inst.rating}</span>
                    <span className="text-zinc-500">({inst.reviewsCount})</span>
                  </div>
                  <div className="flex items-center gap-1 text-[10px] text-zinc-400 mt-1">
                    <MapPin className="w-3 h-3 text-rose-400 shrink-0" />
                    <span className="truncate">{inst.distanceKm} km • {inst.locationName.split(',')[0]}</span>
                  </div>
                </div>
              </div>

              <div className="mt-2.5 pt-2 border-t border-white/5 flex items-center justify-between text-[10px]">
                <span className="text-zinc-400 bg-zinc-800/60 px-2 py-0.5 rounded font-mono">
                  {inst.transmission}
                </span>
                <span className="text-emerald-400 font-medium flex items-center gap-1">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                  {inst.status.split(' ')[0]}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Ongoing Training Status Card */}
      <div className="glass-card rounded-2xl p-4 sm:p-5 border border-white/10 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-center gap-3.5">
          <div className="w-12 h-12 rounded-2xl bg-rose-500/20 border border-rose-500/40 flex items-center justify-center shrink-0">
            <Car className="w-6 h-6 text-rose-400" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="text-xs font-bold text-rose-400 uppercase tracking-wider">
                Status Pelatihanmu
              </span>
              <span className="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2 py-0.5 rounded-full font-medium">
                Aktif (Sesi 3 dari 5)
              </span>
            </div>
            <h3 className="text-sm sm:text-base font-bold text-white mt-0.5">
              Modul 3: Stop & Go Tanjakan Baturraden
            </h3>
            <p className="text-xs text-zinc-400">
              Instruktur: <span className="text-zinc-200 font-medium">{activeInstructor.name}</span> • Toyota Avanza ({activeInstructor.carPlate})
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2.5 w-full md:w-auto">
          <button
            onClick={() => onNavigate('progress')}
            className="flex-1 md:flex-none px-4 py-2 rounded-xl bg-zinc-800 hover:bg-zinc-700 text-xs font-medium text-white border border-white/10 transition cursor-pointer"
          >
            Lihat Rapor
          </button>
          <button
            onClick={() => onNavigate('schedule')}
            className="flex-1 md:flex-none px-4 py-2 rounded-xl bg-rose-500 hover:bg-rose-600 text-xs font-bold text-white shadow-[0_0_15px_rgba(244,63,94,0.4)] transition cursor-pointer"
          >
            Booking Sesi 4
          </button>
        </div>
      </div>

      {/* Pilihan Paket Pelatihan Murni Kursus Mengemudi */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold text-white">Pilihan Paket Kursus Mengemudi</h2>
            <p className="text-xs text-zinc-400">Kurikulum bertahap dari pemula, pemantapan jalan raya, hingga simulasi uji SIM A.</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {PACKAGES.map((pkg) => (
            <div
              key={pkg.id}
              className={`glass-card rounded-2xl p-5 border flex flex-col justify-between relative overflow-hidden transition-all duration-300 ${
                pkg.popular
                  ? 'border-rose-500/50 shadow-[0_0_30px_rgba(244,63,94,0.15)] bg-zinc-900/70'
                  : 'border-white/10 hover:border-white/20'
              }`}
            >
              {pkg.popular && (
                <div className="absolute top-0 right-0 bg-gradient-to-l from-rose-600 to-rose-500 text-white text-[10px] font-bold px-3 py-1 rounded-bl-xl shadow-lg">
                  PALING DIMINATI
                </div>
              )}
              {pkg.badge && (
                <div className="absolute top-0 right-0 bg-gradient-to-l from-amber-600 to-amber-500 text-white text-[10px] font-bold px-3 py-1 rounded-bl-xl shadow-lg">
                  {pkg.badge}
                </div>
              )}

              <div>
                <h3 className="text-base font-bold text-white">{pkg.title}</h3>
                <p className="text-xs text-zinc-400 mt-1 min-h-[32px]">{pkg.subtitle}</p>

                <div className="my-4">
                  <div className="text-xl sm:text-2xl font-extrabold text-white">
                    Rp {pkg.price.toLocaleString('id-ID')}
                  </div>
                  <span className="text-[11px] text-zinc-400">
                    {pkg.sessions} Pertemuan • Total {pkg.hoursTotal} Jam Pelatihan
                  </span>
                </div>

                <div className="space-y-2 border-t border-white/5 pt-3">
                  {pkg.features.map((feat, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-xs text-zinc-300">
                      <ShieldCheck className="w-3.5 h-3.5 text-rose-400 shrink-0 mt-0.5" />
                      <span>{feat}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="mt-5 pt-3 border-t border-white/5 space-y-2">
                <button
                  onClick={() => {
                    onSelectPackage(pkg);
                    onNavigate('search');
                  }}
                  className={`w-full py-2.5 rounded-xl text-xs font-bold transition cursor-pointer flex items-center justify-center gap-1.5 ${
                    pkg.popular
                      ? 'bg-rose-500 hover:bg-rose-600 text-white shadow-[0_0_15px_rgba(244,63,94,0.4)]'
                      : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-100'
                  }`}
                >
                  Pilih Paket & Cari Instruktur
                  <ChevronRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
