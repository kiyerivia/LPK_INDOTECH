import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Lock, Mail, User, Phone, Car, ShieldCheck, ArrowRight, CheckCircle2, AlertCircle } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import confetti from 'canvas-confetti';

export default function AuthModal({ isOpen, onClose }) {
  const { signIn, signUp, isConfigured } = useAuth();
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [selectedRole, setSelectedRole] = useState('siswa'); // 'siswa' | 'mitra'
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setSuccessMsg('');
    setLoading(true);

    try {
      if (isLogin) {
        const { error } = await signIn(email, password);
        if (error) throw error;
        setSuccessMsg('Berhasil masuk! Mengalihkan...');
      } else {
        const { error } = await signUp(email, password, {
          full_name: fullName,
          role: selectedRole,
          phone,
        });
        if (error) throw error;
        setSuccessMsg(
          isConfigured
            ? 'Akun berhasil dibuat! Silakan cek email untuk verifikasi jika diaktifkan.'
            : 'Akun demo berhasil dibuat & langsung aktif!'
        );
      }

      confetti({ particleCount: 50, spread: 60, origin: { y: 0.6 } });
      setTimeout(() => {
        onClose();
      }, 1200);
    } catch (err) {
      setErrorMsg(err.message || 'Terjadi kesalahan saat otentikasi');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md overflow-y-auto">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 15 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 15 }}
        className="relative w-full max-w-md glass-card rounded-3xl p-6 border border-white/10 shadow-2xl overflow-hidden my-6"
      >
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 w-8 h-8 rounded-full bg-zinc-900 border border-white/10 flex items-center justify-center text-zinc-400 hover:text-white transition cursor-pointer"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Header */}
        <div className="text-center space-y-1 mb-5">
          <div className="inline-flex items-center gap-1.5 px-3 py-0.5 rounded-full bg-rose-500/15 border border-rose-500/30 text-rose-300 text-[10px] font-bold">
            <ShieldCheck className="w-3 h-3 text-rose-400" />
            {isConfigured ? 'Supabase Auth Cloud' : 'Supabase Ready (Demo Mode)'}
          </div>
          <h2 className="text-xl font-extrabold text-white">
            {isLogin ? 'Masuk ke Akun LPK' : 'Daftar Akun Baru'}
          </h2>
          <p className="text-xs text-zinc-400">
            {isLogin
              ? 'Akses rapor belajar, jadwal latihan, atau dashboard instruktur'
              : 'Pilih peran dan mulai ekosistem pelatihan mengemudi Anda'}
          </p>
        </div>

        {/* Tab Toggle: Masuk vs Daftar */}
        <div className="grid grid-cols-2 gap-1 bg-zinc-900/80 p-1 rounded-2xl border border-white/10 text-xs mb-4">
          <button
            type="button"
            onClick={() => {
              setIsLogin(true);
              setErrorMsg('');
              setSuccessMsg('');
            }}
            className={`py-2 rounded-xl font-semibold transition cursor-pointer ${
              isLogin
                ? 'bg-rose-500 text-white shadow-[0_0_12px_rgba(244,63,94,0.4)]'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            Masuk
          </button>
          <button
            type="button"
            onClick={() => {
              setIsLogin(false);
              setErrorMsg('');
              setSuccessMsg('');
            }}
            className={`py-2 rounded-xl font-semibold transition cursor-pointer ${
              !isLogin
                ? 'bg-rose-500 text-white shadow-[0_0_12px_rgba(244,63,94,0.4)]'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            Daftar
          </button>
        </div>

        {/* Alerts */}
        {errorMsg && (
          <div className="mb-3 p-3 rounded-xl bg-red-500/15 border border-red-500/30 text-red-300 text-xs flex items-center gap-2">
            <AlertCircle className="w-4 h-4 shrink-0 text-red-400" />
            <span>{errorMsg}</span>
          </div>
        )}
        {successMsg && (
          <div className="mb-3 p-3 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 text-xs flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-400" />
            <span>{successMsg}</span>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-3 text-xs">
          {!isLogin && (
            <>
              {/* Role Selection */}
              <div className="space-y-1.5">
                <label className="text-zinc-300 font-semibold block">Daftar Sebagai:</label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setSelectedRole('siswa')}
                    className={`p-2.5 rounded-xl border flex flex-col items-center gap-1 transition cursor-pointer ${
                      selectedRole === 'siswa'
                        ? 'bg-rose-500/20 border-rose-500 text-rose-300 font-bold'
                        : 'bg-zinc-900 border-white/5 text-zinc-400 hover:text-zinc-200'
                    }`}
                  >
                    <User className="w-4 h-4 text-rose-400" />
                    <span className="text-[11px]">Siswa / Kursus</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setSelectedRole('mitra')}
                    className={`p-2.5 rounded-xl border flex flex-col items-center gap-1 transition cursor-pointer ${
                      selectedRole === 'mitra'
                        ? 'bg-rose-500/20 border-rose-500 text-rose-300 font-bold'
                        : 'bg-zinc-900 border-white/5 text-zinc-400 hover:text-zinc-200'
                    }`}
                  >
                    <Car className="w-4 h-4 text-rose-400" />
                    <span className="text-[11px]">Mitra Instruktur</span>
                  </button>
                </div>
              </div>

              {/* Full Name */}
              <div className="space-y-1">
                <label className="text-zinc-300 font-semibold block">Nama Lengkap:</label>
                <div className="relative">
                  <User className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-3" />
                  <input
                    type="text"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="Contoh: Dimas Aditya"
                    className="w-full bg-zinc-900 border border-white/10 rounded-xl pl-9 pr-3 py-2 text-white placeholder-zinc-500 outline-none focus:border-rose-500"
                    required
                  />
                </div>
              </div>

              {/* Phone */}
              <div className="space-y-1">
                <label className="text-zinc-300 font-semibold block">Nomor WhatsApp:</label>
                <div className="relative">
                  <Phone className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-3" />
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="081234567890"
                    className="w-full bg-zinc-900 border border-white/10 rounded-xl pl-9 pr-3 py-2 text-white placeholder-zinc-500 outline-none focus:border-rose-500"
                    required
                  />
                </div>
              </div>
            </>
          )}

          {/* Email */}
          <div className="space-y-1">
            <label className="text-zinc-300 font-semibold block">Alamat Email:</label>
            <div className="relative">
              <Mail className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-3" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="nama@email.com"
                className="w-full bg-zinc-900 border border-white/10 rounded-xl pl-9 pr-3 py-2 text-white placeholder-zinc-500 outline-none focus:border-rose-500"
                required
              />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-1">
            <label className="text-zinc-300 font-semibold block">Kata Sandi:</label>
            <div className="relative">
              <Lock className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-3" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Minimal 6 karakter"
                className="w-full bg-zinc-900 border border-white/10 rounded-xl pl-9 pr-3 py-2 text-white placeholder-zinc-500 outline-none focus:border-rose-500"
                required
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full mt-2 py-3 rounded-xl bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-500 hover:to-rose-400 text-white font-bold text-xs uppercase tracking-wider shadow-[0_0_20px_rgba(244,63,94,0.4)] transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {loading ? (
              <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
            ) : (
              <>
                {isLogin ? 'Masuk Sekarang' : 'Daftar Akun'}
                <ArrowRight className="w-4 h-4" />
              </>
            )}
          </button>
        </form>
      </motion.div>
    </div>
  );
}
