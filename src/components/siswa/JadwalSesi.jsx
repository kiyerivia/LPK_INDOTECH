import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  Calendar as CalendarIcon, 
  Clock, 
  MapPin, 
  Car, 
  User, 
  Phone, 
  Navigation, 
  CheckCircle2, 
  AlertCircle,
  Plus
} from 'lucide-react';
import { INSTRUCTORS } from '../../data/mockData';

export default function JadwalSesi({ onBookNewSession }) {
  const [sessions, setSessions] = useState([
    {
      id: 'SES-01',
      date: 'Besok, 18 Nov 2026',
      time: '08:00 - 10:00 WIB',
      module: 'Modul 3: Stop & Go Tanjakan Baturraden',
      instructor: INSTRUCTORS[0], // Bambang Sugiantoro
      pickup: 'Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara',
      status: 'confirmed', // confirmed, completed
      car: 'Toyota All New Avanza (Manual)'
    },
    {
      id: 'SES-02',
      date: 'Sabtu, 21 Nov 2026',
      time: '10:30 - 12:30 WIB',
      module: 'Modul 4: Master Parkir Seri & Paralel',
      instructor: INSTRUCTORS[0],
      pickup: 'Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara',
      status: 'scheduled',
      car: 'Toyota All New Avanza (Manual)'
    },
    {
      id: 'SES-00',
      date: '14 Nov 2026',
      time: '08:00 - 10:00 WIB',
      module: 'Modul 2: Manuver Belok & Haluan Jalan Sempit',
      instructor: INSTRUCTORS[0],
      pickup: 'Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara',
      status: 'completed',
      car: 'Toyota All New Avanza (Manual)'
    }
  ]);

  return (
    <div className="space-y-6 pb-28">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <span className="text-xs bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2.5 py-0.5 rounded-full font-bold">
            Manajemen Sesi & Kalender Latihan
          </span>
          <h1 className="text-xl sm:text-2xl font-extrabold text-white mt-1">
            Jadwal Pelatihan Mengemudi
          </h1>
          <p className="text-xs text-zinc-400">
            Jadwal tersinkronisasi otomatis dengan waktu luang instruktur dan buffer perjalanan 30 menit.
          </p>
        </div>

        <button
          onClick={onBookNewSession}
          className="self-start sm:self-auto px-4 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-500 hover:to-rose-400 text-white font-bold text-xs flex items-center gap-2 shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          Booking Sesi Tambahan
        </button>
      </div>

      {/* Next Upcoming Session Focus Card */}
      <div className="relative overflow-hidden rounded-3xl glass-card p-5 sm:p-6 border-2 border-rose-500/50 shadow-[0_0_30px_rgba(244,63,94,0.15)] bg-zinc-900/80">
        <div className="flex items-center justify-between pb-3 border-b border-white/10">
          <div className="flex items-center gap-2">
            <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping" />
            <span className="text-xs font-bold text-rose-400 uppercase tracking-wider">
              Sesi Terdekat Berikutnya
            </span>
          </div>
          <span className="text-xs bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2.5 py-0.5 rounded-full font-semibold">
            Instruktur Siap Menjemput
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
          <div className="space-y-3">
            <div>
              <span className="text-2xl sm:text-3xl font-extrabold text-white">
                Besok, 08:00 WIB
              </span>
              <p className="text-sm font-semibold text-rose-300 mt-0.5">
                Modul 3: Stop & Go Tanjakan Baturraden
              </p>
            </div>

            <div className="space-y-1.5 text-xs text-zinc-300">
              <div className="flex items-center gap-2">
                <MapPin className="w-3.5 h-3.5 text-rose-400 shrink-0" />
                <span className="truncate">Kost Putri Melati, Jl. Kampus Grendeng No. 12</span>
              </div>
              <div className="flex items-center gap-2">
                <Car className="w-3.5 h-3.5 text-zinc-400 shrink-0" />
                <span>Toyota All New Avanza (R 1842 BS) - Manual</span>
              </div>
            </div>
          </div>

          <div className="bg-zinc-950/60 p-4 rounded-2xl border border-white/5 flex flex-col justify-between gap-3">
            <div className="flex items-center gap-3">
              <img
                src={INSTRUCTORS[0].avatar}
                alt="Bambang Sugiantoro"
                className="w-12 h-12 rounded-xl object-cover border border-rose-500/40 shrink-0"
              />
              <div>
                <span className="text-[10px] text-zinc-400 uppercase tracking-wider block">Instruktur Lapangan</span>
                <h4 className="text-sm font-bold text-white">{INSTRUCTORS[0].name}</h4>
                <p className="text-xs text-emerald-400 font-medium">★ 4.9 • 142 Sesi Lulus</p>
              </div>
            </div>

            <div className="flex gap-2">
              <button
                onClick={() => alert('Membuka rute maps ke titik penjemputan siswa di Grendeng...')}
                className="flex-1 py-2 rounded-xl bg-zinc-800 hover:bg-zinc-700 text-xs font-semibold text-zinc-200 border border-white/10 flex items-center justify-center gap-1.5 transition cursor-pointer"
              >
                <Navigation className="w-3.5 h-3.5 text-rose-400" />
                Lacak Armada
              </button>
              <button
                onClick={() => alert('Menghubungi instruktur via WhatsApp LPK...')}
                className="flex-1 py-2 rounded-xl bg-rose-500 hover:bg-rose-600 text-xs font-bold text-white shadow-[0_0_15px_rgba(244,63,94,0.4)] flex items-center justify-center gap-1.5 transition cursor-pointer"
              >
                <Phone className="w-3.5 h-3.5" />
                Kontak WA
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* All Sessions Timeline */}
      <div className="space-y-3">
        <h2 className="text-sm font-bold text-white uppercase tracking-wider">
          Semua Riwayat & Rencana Sesi
        </h2>

        <div className="space-y-3">
          {sessions.map((ses) => (
            <div
              key={ses.id}
              className={`glass-card rounded-2xl p-4 sm:p-5 border flex flex-col sm:flex-row sm:items-center justify-between gap-3 transition ${
                ses.status === 'completed'
                  ? 'border-emerald-500/20 bg-zinc-900/40 opacity-70'
                  : 'border-white/10'
              }`}
            >
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <span className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                    ses.status === 'completed'
                      ? 'bg-emerald-500/20 text-emerald-300'
                      : 'bg-rose-500/20 text-rose-300 border border-rose-500/30'
                  }`}>
                    {ses.status === 'completed' ? 'Sesi Selesai' : 'Terjadwal'}
                  </span>
                  <span className="text-xs text-zinc-400 flex items-center gap-1">
                    <CalendarIcon className="w-3 h-3 text-rose-400" /> {ses.date}
                  </span>
                  <span className="text-xs text-zinc-400 flex items-center gap-1">
                    <Clock className="w-3 h-3 text-zinc-500" /> {ses.time}
                  </span>
                </div>

                <h3 className="text-sm font-bold text-white pt-0.5">{ses.module}</h3>
                <p className="text-xs text-zinc-400">
                  {ses.car} • Instruktur: <span className="text-zinc-200">{ses.instructor.name}</span>
                </p>
              </div>

              <div className="flex items-center gap-2">
                {ses.status === 'completed' ? (
                  <span className="text-xs text-emerald-400 font-semibold flex items-center gap-1">
                    <CheckCircle2 className="w-4 h-4" /> Evaluasi Tercatat
                  </span>
                ) : (
                  <span className="text-xs text-zinc-400 bg-zinc-900 px-3 py-1.5 rounded-xl border border-white/5 font-mono">
                    Penjemputan Door-to-Door
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
