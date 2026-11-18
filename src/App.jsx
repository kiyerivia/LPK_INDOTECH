import React, { useState } from 'react';
import Header from './components/Header';
import NavbarV5 from './components/NavbarV5';
import SiswaHome from './components/siswa/SiswaHome';
import InstrukturFinder from './components/siswa/InstrukturFinder';
import JadwalSesi from './components/siswa/JadwalSesi';
import ProgresBelajar from './components/siswa/ProgresBelajar';
import ProfilSiswa from './components/siswa/ProfilSiswa';
import BookingModal from './components/siswa/BookingModal';
import AuthModal from './components/auth/AuthModal';
import MitraDashboard from './components/mitra/MitraDashboard';
import AdminDashboard from './components/admin/AdminDashboard';
import { AuthProvider, useAuth } from './context/AuthContext';
import { INSTRUCTORS, PACKAGES } from './data/mockData';

function AppContent() {
  const { role, updateRoleLocally } = useAuth();
  const [currentRole, setCurrentRole] = useState(role || 'siswa'); // 'siswa' | 'mitra' | 'admin'
  const [activeTab, setActiveTab] = useState('home'); // 'home' | 'search' | 'schedule' | 'progress' | 'profile'
  const [searchQuery, setSearchQuery] = useState('');
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  
  // Booking modal state
  const [bookingModal, setBookingModal] = useState({
    isOpen: false,
    instructor: INSTRUCTORS[0],
    selectedPackage: PACKAGES[0],
  });

  const handleOpenBooking = (instructor, pkg = null) => {
    setBookingModal({
      isOpen: true,
      instructor: instructor || INSTRUCTORS[0],
      selectedPackage: pkg || PACKAGES[0],
    });
  };

  const handleCloseBooking = () => {
    setBookingModal(prev => ({ ...prev, isOpen: false }));
  };

  const handleBookingSuccess = (bookingData) => {
    setTimeout(() => {
      setActiveTab('schedule');
    }, 1200);
  };

  const handleRoleChange = (newRole) => {
    setCurrentRole(newRole);
    updateRoleLocally(newRole);
    if (newRole === 'siswa') setActiveTab('home');
  };

  return (
    <div className="min-h-screen bg-zinc-950 text-zinc-100 relative overflow-x-hidden selection:bg-rose-500 selection:text-white">
      {/* Ambient Lighting Gradients (Glassy backdrop effects) */}
      <div className="fixed top-0 left-1/4 w-96 h-96 bg-rose-600/10 rounded-full blur-[128px] pointer-events-none z-0" />
      <div className="fixed bottom-1/4 right-1/4 w-96 h-96 bg-red-600/8 rounded-full blur-[140px] pointer-events-none z-0" />
      <div className="fixed top-1/2 right-10 w-72 h-72 bg-blue-600/8 rounded-full blur-[120px] pointer-events-none z-0" />

      {/* Main Header with Role Switcher & Auth */}
      <Header
        currentRole={currentRole}
        setCurrentRole={handleRoleChange}
        onOpenAuth={() => setIsAuthOpen(true)}
      />

      {/* Main Content Area */}
      <main className="relative z-10 max-w-5xl mx-auto px-4 pt-5 pb-10">
        {currentRole === 'siswa' && (
          <>
            {activeTab === 'home' && (
              <SiswaHome
                onNavigate={(tab) => setActiveTab(tab)}
                onSelectPackage={(pkg) => handleOpenBooking(INSTRUCTORS[0], pkg)}
                onSelectInstructor={(inst) => handleOpenBooking(inst, PACKAGES[0])}
              />
            )}

            {activeTab === 'search' && (
              <InstrukturFinder
                searchQuery={searchQuery}
                setSearchQuery={setSearchQuery}
                onSelectForBooking={(inst) => handleOpenBooking(inst, PACKAGES[0])}
              />
            )}

            {activeTab === 'schedule' && (
              <JadwalSesi
                onBookNewSession={() => handleOpenBooking(INSTRUCTORS[0], PACKAGES[0])}
              />
            )}

            {activeTab === 'progress' && <ProgresBelajar />}

            {activeTab === 'profile' && (
              <ProfilSiswa onNavigate={(tab) => setActiveTab(tab)} />
            )}
          </>
        )}

        {currentRole === 'mitra' && (
          <MitraDashboard />
        )}

        {currentRole === 'admin' && (
          <AdminDashboard />
        )}
      </main>

      {/* Booking & Checkout Modal */}
      <BookingModal
        isOpen={bookingModal.isOpen}
        instructor={bookingModal.instructor}
        selectedPackage={bookingModal.selectedPackage}
        onClose={handleCloseBooking}
        onBookingSuccess={handleBookingSuccess}
      />

      {/* Supabase Auth Modal (Login / Register) */}
      <AuthModal
        isOpen={isAuthOpen}
        onClose={() => setIsAuthOpen(false)}
      />

      {/* Floating Dark Glass Navbar with Neon Arch (Video V5) */}
      <NavbarV5
        activeTab={activeTab}
        setActiveTab={(tab) => {
          if (currentRole !== 'siswa') handleRoleChange('siswa');
          setActiveTab(tab);
        }}
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
      />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}
