-- ========================================================
-- LPK CITRA INDOTECH JAYA - MULTI-LPK ECOSYSTEM SCHEMA
-- Hierarchy:
--   1. INDOTECH (Master)     -> role = 'master'
--   2. LPK (Super Admin)     -> role = 'lpk_admin'
--   3. Mitra (Driver)        -> role = 'mitra'
--   4. Konsumen / User       -> role = 'siswa'
-- ========================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Multi-LPK Branches Table (Verified & Governed by INDOTECH Master)
CREATE TABLE IF NOT EXISTS public.lpks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  license_number TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  owner_phone TEXT,
  verification_status TEXT CHECK (verification_status IN ('pending', 'verified', 'suspended')) DEFAULT 'pending',
  lpk_split_percent INTEGER DEFAULT 27,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. User Profiles Table (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  role TEXT CHECK (role IN ('master', 'lpk_admin', 'mitra', 'siswa')) DEFAULT 'siswa',
  lpk_id UUID REFERENCES public.lpks(id) ON DELETE SET NULL,
  verified_by_master BOOLEAN DEFAULT TRUE,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. Mitra / Trainer Details Table
CREATE TABLE IF NOT EXISTS public.mitra_details (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
  lpk_id UUID REFERENCES public.lpks(id) ON DELETE SET NULL,
  car_model TEXT NOT NULL,
  car_plate TEXT NOT NULL,
  transmission TEXT NOT NULL,
  has_dual_pedal BOOLEAN DEFAULT TRUE,
  dual_pedal_proof TEXT,
  kyc_status TEXT CHECK (kyc_status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
  rating NUMERIC(2,1) DEFAULT 5.0,
  reviews_count INTEGER DEFAULT 0,
  hourly_rate INTEGER DEFAULT 85000,
  service_radius_km NUMERIC(3,1) DEFAULT 7.0,
  location_name TEXT DEFAULT 'Purwokerto Utara',
  is_online BOOLEAN DEFAULT TRUE,
  wallet_balance INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. Student / Consumer Profiles Table
CREATE TABLE IF NOT EXISTS public.student_profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
  lpk_id UUID REFERENCES public.lpks(id) ON DELETE SET NULL,
  active_package_id TEXT DEFAULT 'PKG-2',
  completed_sessions INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 10,
  saved_pickup_address TEXT,
  transmission_preference TEXT DEFAULT 'Manual',
  sim_a_status TEXT DEFAULT 'Dalam Pelatihan',
  certificate_number TEXT,
  certificate_approved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. Bookings / Orders Table (Shared real-time across Konsumen -> Mitra -> LPK -> Master)
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  lpk_id UUID REFERENCES public.lpks(id) ON DELETE SET NULL,
  student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  mitra_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  session_date TEXT NOT NULL,
  time_slot TEXT NOT NULL,
  pickup_address TEXT NOT NULL,
  transmission TEXT NOT NULL,
  total_price INTEGER NOT NULL,
  mitra_fee INTEGER NOT NULL,
  lpk_fee INTEGER NOT NULL,
  platform_fee INTEGER NOT NULL,
  status TEXT CHECK (status IN ('pending', 'accepted', 'on_the_way', 'arrived', 'training', 'completed', 'cancelled')) DEFAULT 'pending',
  payment_method TEXT DEFAULT 'qris',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 7. Session Evaluations Table (Rapor Siswa)
CREATE TABLE IF NOT EXISTS public.session_evaluations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  instructor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  module_number INTEGER NOT NULL,
  module_title TEXT NOT NULL,
  score INTEGER CHECK (score >= 0 AND score <= 100),
  instructor_notes TEXT,
  skills_checklist JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 8. Automated Trigger to create public.profiles upon auth.users sign up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Pengguna Baru'),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'siswa')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 9. Row Level Security (RLS)
ALTER TABLE public.lpks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mitra_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_evaluations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Verified LPKs viewable by everyone." ON public.lpks FOR SELECT USING (verification_status = 'verified' OR EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role IN ('master', 'lpk_admin')));
CREATE POLICY "Public profiles viewable." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Mitra details viewable." ON public.mitra_details FOR SELECT USING (true);
CREATE POLICY "Bookings viewable by participants or admins." ON public.bookings FOR SELECT USING (
  auth.uid() = student_id
  OR auth.uid() = mitra_id
  OR EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role IN ('master', 'lpk_admin'))
);
