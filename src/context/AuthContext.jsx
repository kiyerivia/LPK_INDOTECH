import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase, isSupabaseConfigured } from '../lib/supabaseClient';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState({
    id: 'demo-user-1',
    full_name: 'Dimas Aditya Pratama',
    role: 'siswa',
    phone: '081234567890',
    avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isSupabaseConfigured()) {
      setLoading(false);
      return;
    }

    // Check active session on mount
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
      if (session?.user) {
        fetchProfile(session.user.id);
      } else {
        setLoading(false);
      }
    });

    // Listen to auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
      if (session?.user) {
        fetchProfile(session.user.id);
      } else {
        setProfile(null);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const fetchProfile = async (userId) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Error fetching profile:', error);
      } else if (data) {
        setProfile(data);
      }
    } catch (err) {
      console.error('Failed to load profile:', err);
    } finally {
      setLoading(false);
    }
  };

  const signUp = async (email, password, metadata) => {
    if (!isSupabaseConfigured()) {
      // Demo mock mode
      const mockUser = { id: `mock-${Date.now()}`, email };
      const mockProfile = {
        id: mockUser.id,
        full_name: metadata.full_name || 'Pengguna Baru',
        role: metadata.role || 'siswa',
        phone: metadata.phone || '',
      };
      setUser(mockUser);
      setProfile(mockProfile);
      return { data: { user: mockUser }, error: null };
    }

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: metadata.full_name,
          role: metadata.role,
          phone: metadata.phone,
        },
      },
    });

    if (!error && data.user) {
      // Create profile row in profiles table
      await supabase.from('profiles').insert([
        {
          id: data.user.id,
          full_name: metadata.full_name,
          role: metadata.role || 'siswa',
          phone: metadata.phone || '',
          avatar_url: metadata.avatar_url || null,
        },
      ]);
    }

    return { data, error };
  };

  const signIn = async (email, password) => {
    if (!isSupabaseConfigured()) {
      // Demo mock mode
      const mockUser = { id: 'demo-user-1', email };
      setUser(mockUser);
      return { data: { user: mockUser }, error: null };
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (!error && data.user) {
      await fetchProfile(data.user.id);
    }

    return { data, error };
  };

  const signOut = async () => {
    if (isSupabaseConfigured()) {
      await supabase.auth.signOut();
    }
    setUser(null);
    setProfile(null);
  };

  const updateRoleLocally = (newRole) => {
    setProfile(prev => ({ ...prev, role: newRole }));
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        profile,
        role: profile?.role || 'siswa',
        loading,
        signUp,
        signIn,
        signOut,
        updateRoleLocally,
        isConfigured: isSupabaseConfigured(),
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
