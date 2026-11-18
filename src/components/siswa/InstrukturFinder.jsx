import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  MapPin, 
  Star, 
  ShieldCheck, 
  Car, 
  Calendar, 
  Clock, 
  Filter, 
  CheckCircle2, 
  User, 
  SlidersHorizontal,
  Navigation
} from 'lucide-react';
import { INSTRUCTORS } from '../../data/mockData';

export default function InstrukturFinder({ onSelectForBooking, searchQuery, setSearchQuery }) {
  const [selectedRadius, setSelectedRadius] = useState(5); // km
  const [selectedTransmission, setSelectedTransmission] = useState('all'); // all, Manual, Matic
  const [activePin, setActivePin] = useState(INSTRUCTORS[0].id);

  // Filter instructors
  const filteredInstructors = INSTRUCTORS.filter((inst) => {
    // Radius filter
    if (inst.distanceKm > selectedRadius) return false;

    // Transmission filter
    if (selectedTransmission !== 'all') {
      if (selectedTransmission === 'Manual' && !inst.transmission.includes('Manual')) return false;
      if (selectedTransmission === 'Matic' && !inst.transmission.includes('Matic')) return false;
    }

    // Search query filter
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      const matchName = inst.name.toLowerCase().includes(q);
      const matchLoc = inst.locationName.toLowerCase().includes(q);
      const matchCar = inst.carModel.toLowerCase().includes(q);
      const matchTrans = inst.transmission.toLowerCase().includes(q);
      if (!matchName && !matchLoc && !matchCar && !matchTrans) return false;
    }

    return true;
  });

  return (
    <div className="space-y-6 pb-28">
      {/* Header & Geolocation Status */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl sm:text-2xl font-extrabold text-white">
              Cari Instruktur Terdekat
            </h1>
            <span className="text-xs bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2 py-0.5 rounded-full font-bold">
              GPS Auto-Detect
            </span>
          </div>
          <p className="text-xs text-zinc-400 mt-1 flex items-center gap-1.5">
            <MapPin className="w-3.5 h-3.5 text-rose-500" />
            Titik Jemput: <span className="text-zinc-200 font-medium">Grendeng, Purwokerto Utara</span> (±3.2 km dari pusat kota)
          </p>
        </div>

        {/* Radius Filter Pills */}
        <div className="flex items-center gap-1.5 bg-zinc-900/90 border border-white/10 p-1 rounded-xl self-start sm:self-auto text-xs">
          <span className="text-[10px] text-zinc-400 px-2 flex items-center gap-1">
            <SlidersHorizontal className="w-3 h-3" /> Radius:
          </span>
          {[3, 5, 10].map((radius) => (
            <button
              key={radius}
              onClick={() => setSelectedRadius(radius)}
              className={`px-2.5 py-1 rounded-lg text-xs font-semibold transition cursor-pointer ${
                selectedRadius === radius
                  ? 'bg-rose-500 text-white shadow-[0_0_10px_rgba(244,63,94,0.4)]'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              {radius} km
            </button>
          ))}
        </div>
      </div>

      {/* Interactive Geolocation Radar / Map Simulation */}
      <div className="glass-card rounded-3xl p-5 border border-white/10 relative overflow-hidden">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <div className="w-2.5 h-2.5 rounded-full bg-rose-500 animate-pulse" />
            <span className="text-xs font-bold text-white tracking-wider uppercase">
              Simulasi Peta Wilayah Purwokerto
            </span>
          </div>
          <span className="text-[11px] text-zinc-400">
            Ditemukan <strong className="text-rose-400">{filteredInstructors.length}</strong> mitra aktif
          </span>
        </div>

        {/* Visual Simulated Map Grid */}
        <div className="relative w-full h-56 sm:h-64 rounded-2xl bg-zinc-950 border border-white/10 overflow-hidden bg-grid-pattern flex items-center justify-center">
          {/* Concentric Radar Rings */}
          <div className="absolute w-28 h-28 rounded-full border border-rose-500/15 pointer-events-none" />
          <div className="absolute w-56 h-56 rounded-full border border-rose-500/10 pointer-events-none" />
          <div className="absolute w-84 h-84 rounded-full border border-white/5 pointer-events-none" />

          {/* Student Center Pin */}
          <div className="relative z-20 flex flex-col items-center">
            <div className="w-10 h-10 rounded-full bg-rose-500 text-white flex items-center justify-center shadow-[0_0_20px_rgba(244,63,94,0.8)] border-2 border-white animate-bounce">
              <User className="w-5 h-5" />
            </div>
            <div className="bg-zinc-900/90 text-[10px] text-rose-300 border border-rose-500/30 px-2 py-0.5 rounded-full font-bold shadow-md mt-1">
              Kamu (Siswa)
            </div>
          </div>

          {/* Instructor Pins on Map (Simulated coordinates) */}
          {INSTRUCTORS.map((inst, idx) => {
            const positions = [
              { top: '22%', left: '26%' },
              { top: '30%', right: '28%' },
              { bottom: '20%', left: '32%' },
              { bottom: '26%', right: '24%' },
            ];
            const pos = positions[idx % positions.length];
            const isSelected = activePin === inst.id;

            return (
              <motion.div
                key={inst.id}
                style={pos}
                whileHover={{ scale: 1.15 }}
                onClick={() => setActivePin(inst.id)}
                className={`absolute z-20 cursor-pointer flex flex-col items-center group transition`}
              >
                <div
                  className={`px-2 py-1 rounded-xl text-[10px] font-bold flex items-center gap-1.5 shadow-lg border transition ${
                    isSelected
                      ? 'bg-rose-500 text-white border-white shadow-[0_0_15px_rgba(244,63,94,0.7)]'
                      : 'bg-zinc-900/90 text-zinc-200 border-white/20 group-hover:border-rose-400'
                  }`}
                >
                  <Car className="w-3 h-3 text-white" />
                  <span>{inst.name.split(' ')[0]}</span>
                  <span className="text-[9px] opacity-80">({inst.distanceKm}km)</span>
                </div>
                <div
                  className={`w-2 h-2 rotate-45 -mt-1 ${
                    isSelected ? 'bg-rose-500' : 'bg-zinc-900'
                  }`}
                />
              </motion.div>
            );
          })}

          {/* Compass Rose */}
          <div className="absolute top-3 right-3 text-zinc-600 flex flex-col items-center text-[9px] font-mono pointer-events-none">
            <span>U (Baturraden)</span>
            <Navigation className="w-3.5 h-3.5 rotate-45 text-rose-500/50" />
            <span>S</span>
          </div>
        </div>
      </div>

      {/* Filter Transmisi Tabs */}
      <div className="flex items-center gap-2 border-b border-white/10 pb-3">
        <span className="text-xs text-zinc-400">Pilih Transmisi:</span>
        {['all', 'Manual', 'Matic'].map((type) => (
          <button
            key={type}
            onClick={() => setSelectedTransmission(type)}
            className={`px-3 py-1 rounded-lg text-xs font-medium transition cursor-pointer ${
              selectedTransmission === type
                ? 'bg-zinc-800 text-white border border-rose-500/40 shadow-sm'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            {type === 'all' ? 'Semua Mobil' : type}
          </button>
        ))}
      </div>

      {/* Instructors List */}
      <div className="space-y-4">
        {filteredInstructors.length === 0 ? (
          <div className="glass-card rounded-2xl p-8 text-center text-zinc-400 border border-white/10">
            <p className="text-sm">Tidak ada instruktur dalam radius {selectedRadius} km dengan filter yang dipilih.</p>
            <button
              onClick={() => {
                setSelectedRadius(10);
                setSelectedTransmission('all');
                setSearchQuery('');
              }}
              className="mt-3 text-xs text-rose-400 hover:underline"
            >
              Perluas radius pencarian ke 10 km
            </button>
          </div>
        ) : (
          filteredInstructors.map((inst) => {
            const isSelected = activePin === inst.id;

            return (
              <motion.div
                key={inst.id}
                layout
                className={`glass-card rounded-2xl p-4 sm:p-5 border transition-all duration-300 ${
                  isSelected
                    ? 'border-rose-500/60 shadow-[0_0_30px_rgba(244,63,94,0.15)] bg-zinc-900/80'
                    : 'border-white/10 hover:border-white/20'
                }`}
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                  {/* Instructor Bio & Car Info */}
                  <div className="flex items-start gap-4">
                    <img
                      src={inst.avatar}
                      alt={inst.name}
                      className="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl object-cover border-2 border-rose-500/40 shrink-0 shadow-lg"
                    />
                    <div className="space-y-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <h3 className="text-sm sm:text-base font-bold text-white">
                          {inst.name}
                        </h3>
                        <span className="text-[10px] bg-rose-500/15 text-rose-300 border border-rose-500/30 px-2 py-0.5 rounded-full font-bold">
                          {inst.transmission}
                        </span>
                      </div>

                      <div className="flex items-center gap-2 text-xs text-zinc-300">
                        <div className="flex items-center gap-1 text-amber-400">
                          <Star className="w-3.5 h-3.5 fill-amber-400" />
                          <span className="font-bold">{inst.rating}</span>
                        </div>
                        <span className="text-zinc-500">•</span>
                        <span className="text-zinc-400">{inst.reviewsCount} Siswa Lulus</span>
                        <span className="text-zinc-500">•</span>
                        <span className="text-rose-400 font-semibold">{inst.distanceKm} km dari lokasimu</span>
                      </div>

                      <p className="text-xs text-zinc-300 flex items-center gap-1.5 pt-0.5">
                        <Car className="w-3.5 h-3.5 text-zinc-400 shrink-0" />
                        <span>{inst.carModel} <span className="font-mono text-zinc-400">({inst.carPlate})</span></span>
                      </p>

                      <div className="flex items-center gap-1 text-[11px] text-emerald-400 font-medium">
                        <ShieldCheck className="w-3.5 h-3.5 text-emerald-400 shrink-0" />
                        <span>{inst.dualPedal}</span>
                      </div>
                    </div>
                  </div>

                  {/* Actions & Booking */}
                  <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-center border-t sm:border-t-0 border-white/5 pt-3 sm:pt-0 gap-2 shrink-0">
                    <div className="text-left sm:text-right">
                      <span className="text-[10px] text-zinc-400 uppercase tracking-wider block">Estimasi Tarif</span>
                      <span className="text-sm sm:text-base font-extrabold text-white">
                        Rp {inst.hourlyRate.toLocaleString('id-ID')}
                        <span className="text-xs font-normal text-zinc-400">/jam</span>
                      </span>
                    </div>

                    <button
                      onClick={() => onSelectForBooking(inst)}
                      className="px-4 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-500 hover:to-rose-400 text-white text-xs font-bold shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer flex items-center gap-1.5"
                    >
                      <Calendar className="w-3.5 h-3.5" />
                      Pilih & Booking Jadwal
                    </button>
                  </div>
                </div>

                {/* Available Slots Preview */}
                <div className="mt-4 pt-3 border-t border-white/5 flex flex-wrap items-center gap-2">
                  <span className="text-[11px] text-zinc-400 flex items-center gap-1">
                    <Clock className="w-3 h-3 text-rose-400" />
                    Slot Tersedia Hari Ini / Besok:
                  </span>
                  {inst.availableSlots.map((slot, sIdx) => (
                    <span
                      key={sIdx}
                      className="text-[11px] bg-zinc-900 border border-white/10 text-zinc-300 px-2.5 py-0.5 rounded-lg"
                    >
                      {slot}
                    </span>
                  ))}
                  <span className="text-[10px] text-zinc-500 italic ml-auto">
                    + Jeda 30 menit antar siswa
                  </span>
                </div>
              </motion.div>
            );
          })
        )}
      </div>
    </div>
  );
}
