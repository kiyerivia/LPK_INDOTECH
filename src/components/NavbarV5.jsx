import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Home, Search, Calendar, Award, User, X } from 'lucide-react';

export default function NavbarV5({ activeTab, setActiveTab, searchQuery, setSearchQuery }) {
  const [showSearchPopup, setShowSearchPopup] = useState(false);

  const navItems = [
    { id: 'home', label: 'Beranda', icon: Home },
    { id: 'search', label: 'Cari', icon: Search },
    { id: 'schedule', label: 'Jadwal', icon: Calendar },
    { id: 'progress', label: 'Rapor', icon: Award },
    { id: 'profile', label: 'Profil', icon: User },
  ];

  const handleTabClick = (id) => {
    setActiveTab(id);
    if (id === 'search') {
      setShowSearchPopup(true);
    } else {
      setShowSearchPopup(false);
    }
  };

  return (
    <div className="fixed bottom-6 left-0 right-0 z-50 flex flex-col items-center pointer-events-none px-4">
      {/* Floating Search Pill Popup (Preserved from Video Frame 04) */}
      <AnimatePresence>
        {showSearchPopup && activeTab === 'search' && (
          <motion.div
            initial={{ opacity: 0, y: 15, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            transition={{ duration: 0.25, ease: 'easeOut' }}
            className="pointer-events-auto mb-3 w-full max-w-md bg-zinc-900/90 backdrop-blur-2xl border border-white/10 rounded-full px-4 py-2.5 shadow-2xl flex items-center gap-3"
          >
            <Search className="w-4 h-4 text-rose-500 shrink-0" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Cari instruktur, lokasi Purwokerto, transmisi..."
              className="bg-transparent border-none outline-none text-xs sm:text-sm text-zinc-100 placeholder-zinc-500 w-full"
              autoFocus
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="text-zinc-500 hover:text-zinc-300 p-1"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Main Navbar Pill Container */}
      <div className="pointer-events-auto relative flex items-center justify-between w-full max-w-md bg-zinc-950/90 backdrop-blur-2xl border border-white/10 rounded-full px-3 py-2 shadow-[0_15px_45px_rgba(0,0,0,0.8)]">
        {/* Subtle Bottom Neon Glow Accent Line */}
        <div className="absolute -bottom-[1px] inset-x-8 h-[2px] bg-gradient-to-r from-transparent via-rose-500/70 to-transparent pointer-events-none" />

        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;

          return (
            <button
              key={item.id}
              onClick={() => handleTabClick(item.id)}
              className="relative flex-1 flex flex-col items-center justify-center py-1.5 focus:outline-none cursor-pointer transition-colors duration-200"
            >
              {/* Active Neon Arch Wave (Inspired directly by Video V5) */}
              {isActive && (
                <motion.div
                  layoutId="activeNeonArch"
                  className="absolute -top-3 w-16 h-14 pointer-events-none flex items-center justify-center"
                  transition={{
                    type: 'spring',
                    stiffness: 420,
                    damping: 32,
                  }}
                >
                  {/* Glowing SVG Arch Bell Curve */}
                  <svg
                    className="w-16 h-14 overflow-visible"
                    viewBox="0 0 64 48"
                    fill="none"
                  >
                    <defs>
                      <radialGradient
                        id="archGlow"
                        cx="50%"
                        cy="40%"
                        r="50%"
                      >
                        <stop offset="0%" stopColor="#f43f5e" stopOpacity="0.45" />
                        <stop offset="100%" stopColor="#f43f5e" stopOpacity="0" />
                      </radialGradient>
                      <filter id="neonBlur" x="-20%" y="-20%" width="140%" height="140%">
                        <feGaussianBlur stdDeviation="3" result="blur" />
                        <feMerge>
                          <feMergeNode in="blur" />
                          <feMergeNode in="SourceGraphic" />
                        </feMerge>
                      </filter>
                    </defs>

                    {/* Ambient Radial Glow underneath */}
                    <ellipse cx="32" cy="22" rx="16" ry="12" fill="url(#archGlow)" />

                    {/* Blur / Glow stroke */}
                    <path
                      d="M 2 46 C 14 46, 17 8, 32 8 C 47 8, 50 46, 62 46"
                      stroke="#f43f5e"
                      strokeWidth="4"
                      strokeLinecap="round"
                      className="opacity-70 blur-[3px]"
                    />

                    {/* Sharp Crisp Neon Stroke */}
                    <path
                      d="M 2 46 C 14 46, 17 8, 32 8 C 47 8, 50 46, 62 46"
                      stroke="#ff2453"
                      strokeWidth="2.4"
                      strokeLinecap="round"
                      filter="url(#neonBlur)"
                    />

                    {/* Small center crown jewel dot */}
                    <circle cx="32" cy="8" r="1.8" fill="#ffffff" />
                  </svg>
                </motion.div>
              )}

              {/* Icon Container with subtle pop on active */}
              <motion.div
                animate={{
                  y: isActive ? -4 : 0,
                  scale: isActive ? 1.15 : 1,
                }}
                transition={{ type: 'spring', stiffness: 500, damping: 25 }}
                className="relative z-10"
              >
                <Icon
                  className={`w-5 h-5 transition-colors duration-200 ${
                    isActive
                      ? 'text-rose-500 drop-shadow-[0_0_8px_rgba(244,63,94,0.8)]'
                      : 'text-zinc-400 hover:text-zinc-200'
                  }`}
                  strokeWidth={isActive ? 2.3 : 1.8}
                />
              </motion.div>

              {/* Label */}
              <motion.span
                animate={{
                  opacity: isActive ? 1 : 0.65,
                  scale: isActive ? 1.05 : 0.95,
                }}
                className={`text-[10px] mt-1 font-medium transition-colors duration-200 ${
                  isActive ? 'text-rose-400 font-semibold' : 'text-zinc-400'
                }`}
              >
                {item.label}
              </motion.span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
