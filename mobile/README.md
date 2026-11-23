# LPK Citra Indotech Jaya (CIJ) — 3-App Driving Ecosystem

Platform kursus mengemudi & pendampingan SIM A dengan arsitektur **3 aplikasi terpisah ala Gojek** dari satu codebase Flutter (`mobile/`) dan satu database Supabase.

## 3 Aplikasi & Target Build (`APP_TARGET`)

| # | Aplikasi | Vercel URL | Entrypoint (`APP_TARGET`) | Role |
| :- | :--- | :--- | :--- | :--- |
| **1** | **CIJ Driving** | https://cij-driving.vercel.app | `lib/main_user.dart` | Konsumen / Siswa |
| **2** | **CIJ Partner** | https://cij-partner.vercel.app | `lib/main_mitra.dart` | Mitra Driver / Instruktur |
| **3** | **CIJ Command Center** | https://cij-console.vercel.app | `lib/main_console.dart` | INDOTECH (Master) & LPK (Super Admin) |

## Menjalankan Lokal

```bash
# App 1 — Konsumen / Siswa
flutter run -d chrome -t lib/main_user.dart

# App 2 — Mitra Driver
flutter run -d chrome -t lib/main_mitra.dart

# App 3 — Command Center (Master & LPK)
flutter run -d chrome -t lib/main_console.dart
```

## Auto-Deploy Vercel (GitHub Actions)

- **GitHub Repo:** `kiyerivia/LPK_INDOTECH` (`kiyerivia@gmail.com`)
- **Vercel Hosting:** akun `bintangarifiano@gmail.com` (3 project paralel via `.github/workflows/deploy-vercel.yml`)
- **Supabase Backend:** akun `bintangarifiano@gmail.com`

Setiap push ke branch `main` yang mengubah `mobile/**` akan otomatis mem-build dan men-deploy ketiga aplikasi secara paralel menggunakan secret `VERCEL_TOKEN`.
