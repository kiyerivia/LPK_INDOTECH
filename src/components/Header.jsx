import React from 'react';
import { ShieldCheck, MapPin, Bell, UserCheck, Car, Briefcase } from 'lucide-react';

export default function Header({ currentRole, setCurrentRole, unreadCount = 2 }) {
  return (
    <header className="sticky top-0 z-40 w-full backdrop-blur-xl bg-zinc-950/80 border-b border-white/10 px-4 py-3">
      <div className="max-w-5xl mx-auto flex items-center justify-between gap-2">
        {/* Brand / Logo */}
        <div className="flex items-center gap-2.5">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-rose-600 to-rose-400 flex items-center justify-center shadow-[0_0_20px_rgba(244,63,94,0.4)] border border-rose-300/30">
            <Car className="w-5 h-5 text-white" />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="font-extrabold text-sm sm:text-base tracking-tight text-white">
                LPK <span className="text-rose-500">INDOTECH</span>
              </span>
              <span className="text-[10px] bg-rose-500/20 text-rose-300 border border-rose-500/30 px-1.5 py-0.5 rounded font-mono font-bold">
                PARTNER
              </span>
            </div>
            <div className="flex items-center gap-1 text-[11px] text-zinc-400">
              <span className="inline-block w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
              <MapPin className="w-3 h-3 text-zinc-500" />
              <span className="truncate max-w-[140px] sm:max-w-xs">Purwokerto Utara</span>
            </div>
          </div>
        </div>

        {/* Role Switcher (Crucial for Demoing Siswa vs Mitra vs Admin!) */}
        <div className="flex items-center gap-1.5 bg-zinc-900/90 border border-white/10 rounded-full p-1 text-xs">
          <button
            onClick={() => setCurrentRole('siswa')}
            className={`px-2.5 py-1 rounded-full text-[11px] font-medium transition-all ${
              currentRole === 'siswa'
                ? 'bg-rose-500 text-white shadow-[0_0_12px_rgba(244,63,94,0.5)]'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            Siswa
          </button>
          <button
            onClick={() => setCurrentRole('mitra')}
            className={`px-2.5 py-1 rounded-full text-[11px] font-medium transition-all ${
              currentRole === 'mitra'
                ? 'bg-rose-500 text-white shadow-[0_0_12px_rgba(244,63,94,0.5)]'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            Mitra
          </button>
          <button
            onClick={() => setCurrentRole('admin')}
            className={`px-2.5 py-1 rounded-full text-[11px] font-medium transition-all ${
              currentRole === 'admin'
                ? 'bg-rose-500 text-white shadow-[0_0_12px_rgba(244,63,94,0.5)]'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            Admin LPK
          </button>
        </div>

        {/* Notification Bell */}
        <div className="relative">
          <button className="w-8 h-8 rounded-full bg-zinc-900 border border-white/10 flex items-center justify-center text-zinc-300 hover:text-white transition">
            <Bell className="w-4 h-4" />
          </button>
          {unreadCount > 0 && (
            <span className="absolute -top-1 -right-1 w-4 h-4 bg-rose-500 text-white text-[9px] font-bold rounded-full flex items-center justify-center border-2 border-zinc-950">
              {unreadCount}
            </span>
          )}
        </div>
      </div>
    </header>
  );
}
