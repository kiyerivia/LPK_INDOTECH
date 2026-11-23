# LPK Citra Indotech Jaya (CIJ) — Multi-App Driving Ecosystem

Platform kursus mengemudi & pendampingan SIM A dengan arsitektur **3 aplikasi terpisah ala Gojek + 1 Portal Ekosistem** dari satu codebase Flutter (`mobile/`) dan satu database Supabase.

## Aplikasi & Target Build (`APP_TARGET`)

| Aplikasi | Vercel URL | Entrypoint (`APP_TARGET`) | Role |
| :--- | :--- | :--- | :--- |
| **CIJ Driving** | https://cij-driving.vercel.app | `lib/main_user.dart` | Konsumen / Siswa |
| **CIJ Partner** | https://cij-partner.vercel.app | `lib/main_mitra.dart` | Mitra Driver / Instruktur |
| **CIJ Command Center** | https://cij-console.vercel.app | `lib/main_console.dart` | INDOTECH (Master) & LPK (Super Admin) |
| **Portal Ekosistem** | https://lpk-indotech.vercel.app | `lib/main.dart` | Launcher Demo 3 Aplikasi |

## Menjalankan Lokal

```bash
# Portal Launcher (semua aplikasi)
flutter run -d chrome

# Standalone Konsumen / Siswa
flutter run -d chrome -t lib/main_user.dart

# Standalone Mitra Driver
flutter run -d chrome -t lib/main_mitra.dart

# Standalone Command Center (Master & LPK)
flutter run -d chrome -t lib/main_console.dart
```

## Auto-Deploy Vercel (GitHub Actions)

- **GitHub Repo:** `kiyerivia/LPK_INDOTECH` (`kiyerivia@gmail.com`)
- **Vercel Hosting:** akun `bintangarifiano@gmail.com` (4 project paralel via `.github/workflows/deploy-vercel.yml`)
- **Supabase Backend:** akun `bintangarifiano@gmail.com`

Setiap push ke branch `main` yang mengubah `mobile/**` akan otomatis mem-build dan men-deploy keempat aplikasi secara paralel menggunakan secret `VERCEL_TOKEN` (`Deploy CIJ Multi-App Ecosystem to Vercel`).

