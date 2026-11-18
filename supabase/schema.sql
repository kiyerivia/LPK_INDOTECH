-- ========================================================
-- LPK INDOTECH DRIVING ACADEMY - SUPABASE DATABASE SCHEMA
-- ========================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create User Profiles Table (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  role TEXT CHECK (role IN ('siswa', 'mitra', 'admin')) DEFAULT 'siswa',
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Create Mitra / Trainer Details Table
CREATE TABLE IF NOT EXISTS public.mitra_details (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
  car_model TEXT NOT NULL,
  car_plate TEXT NOT NULL,
  transmission TEXT NOT NULL, -- 'Manual', 'Matic', 'Manual & Matic'
  has_dual_pedal BOOLEAN DEFAULT TRUE,
  dual_pedal_proof TEXT,
  rating NUMERIC(2,1) DEFAULT 5.0,
  reviews_count INTEGER DEFAULT 0,
  hourly_rate INTEGER DEFAULT 85000,
  distance_km NUMERIC(3,1) DEFAULT 2.5,
  location_name TEXT DEFAULT 'Purwokerto Utara',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. Create Student Profiles Table
CREATE TABLE IF NOT EXISTS public.student_profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
  active_package_id TEXT DEFAULT 'pkg-basic',
  completed_sessions INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 5,
  saved_pickup_address TEXT,
  transmission_preference TEXT DEFAULT 'Manual',
  sim_a_status TEXT DEFAULT 'Belum Punya',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. Create Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
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
  status TEXT CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')) DEFAULT 'pending',
  payment_method TEXT DEFAULT 'qris',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. Create Session Evaluations Table (Rapor Siswa)
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

-- 7. Automated Trigger to create public.profiles upon auth.users sign up
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

-- 8. Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mitra_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_evaluations ENABLE ROW LEVEL SECURITY;

-- Read policies (Allow users to read their own profile, and public to read active mitra)
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Mitra details viewable by everyone." ON public.mitra_details FOR SELECT USING (true);
CREATE POLICY "Bookings viewable by involved student or mitra." ON public.bookings FOR SELECT USING (auth.uid() = student_id OR auth.uid() = mitra_id);
