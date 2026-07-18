# Catatan Perubahan Day 2 - Supabase Backend

Dokumen ini untuk bahan pembahasan meeting Day 2 jam 8 malam. Fokus perubahan: UI peserta tetap dipakai, struktur folder dirapikan, lalu semua data utama yang sudah muncul di UI disambungkan ke Supabase.

## Backend yang Dipakai

Backend diganti dari Firebase menjadi Supabase:

- Supabase Auth untuk login, register, dan Google OAuth.
- Supabase Database/Postgres untuk profile, alamat, request penjemputan, dan notifikasi.
- Row Level Security agar user hanya bisa akses datanya sendiri.

Setup tabel ada di:

```txt
supabase_schema.sql
```

## Struktur Folder

Screen dipindahkan ke folder:

```txt
lib/screens/
```

Widget reusable:

```txt
lib/widgets/
```

Service backend:

```txt
lib/services/
```

Model data:

```txt
lib/models/
```

Ini tidak mengubah UI. Tujuannya hanya supaya dosen/peserta melihat struktur project lebih rapi.

## Data yang Dibutuhkan dari UI

Tabel Supabase yang dipakai:

```txt
profiles
pickup_requests
notifications
```

`profiles` dipakai untuk:

- nama user,
- email,
- nomor WhatsApp,
- alamat,
- detail alamat,
- QR user,
- profile page,
- greeting dashboard.

`pickup_requests` dipakai untuk:

- kategori sampah yang dipilih,
- jumlah,
- satuan,
- status request,
- riwayat request penjemputan.

`notifications` dipakai untuk:

- notifikasi request berhasil,
- badge unread di dashboard,
- halaman notifikasi.

Kategori sampah tetap static di Flutter karena membawa asset puzzle, warna, dan layout lokal.

## File Baru

```txt
lib/services/supabase_service.dart
lib/services/auth_service.dart
lib/services/user_service.dart
lib/services/pickup_request_service.dart
lib/services/notification_service.dart
lib/models/app_user.dart
lib/models/pickup_request.dart
lib/core/routes/app_routes.dart
supabase_schema.sql
```

## File Screen yang Disambungkan

```txt
lib/screens/login_screen.dart
lib/screens/signUp.dart
lib/screens/splash_screen.dart
lib/screens/verifOTP.dart
lib/screens/add_address_page.dart
lib/screens/dashboard_page.dart
lib/screens/category_detail_page.dart
lib/screens/pickup_confirmation_page.dart
lib/screens/pickup_request_list_page.dart
lib/screens/notification_page.dart
lib/screens/profile_screen.dart
lib/screens/edit_profile.dart
lib/screens/edit_alamat.dart
lib/screens/qr_generator.dart
```

## Alur Backend Sekarang

Register:

```txt
SignUp screen
-> Supabase Auth signUp
-> upsert profiles
-> OTP demo
-> Add Address
```

Login:

```txt
Login screen
-> Supabase Auth signInWithPassword
-> Dashboard
```

Google login:

```txt
Login screen
-> Supabase Auth signInWithOAuth Google
-> kembali ke app/browser
-> Splash cek session Supabase
-> upsert profiles
-> Dashboard
```

Alamat:

```txt
AddAddress/EditAlamat
-> upsert profiles
```

Dashboard:

```txt
Dashboard
-> read profiles
-> read notifications untuk badge
-> read pickup_requests untuk status jadwal terakhir
-> tombol List sampah diajukan membuka riwayat request dari Supabase
```

Kategori dan request:

```txt
CategoryDetail
-> PickupConfirmation
-> insert pickup_requests
-> insert notifications
```

List sampah diajukan:

```txt
PickupRequestListPage
-> read pickup_requests milik user login
-> tampilkan kategori, jumlah, status, dan waktu request
```

QR:

```txt
QR screen
-> read profiles
-> generate QR dari data user
```

Profile:

```txt
Profile/EditProfile
-> read/update profiles
```

Notifikasi:

```txt
NotificationPage
-> read notifications
-> mark all as read
```

## Cara Setup Supabase

1. Buat project di Supabase.
2. Buka SQL Editor.
3. Copy isi `supabase_schema.sql`.
4. Klik Run.
5. Buka Authentication -> Providers.
6. Enable Email provider.
7. Untuk kelas, matikan Confirm email agar setelah register peserta langsung punya session dan bisa insert `profiles`.
8. Enable Google provider jika ingin demo Google OAuth.
9. Ambil Project URL dan anon/publishable key dari Project Settings -> API.

Jalankan Flutter:

```bash
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=ISI_PROJECT_URL --dart-define=SUPABASE_ANON_KEY=ISI_ANON_KEY
```

## Catatan untuk Dijelaskan ke Peserta

Supabase Auth dan tabel database itu berbeda. Auth menyimpan identitas login, sedangkan tabel `profiles` menyimpan data aplikasi seperti nama, nomor WhatsApp, dan alamat.

OTP di project ini masih simulasi:

```txt
123456
```

OTP production tidak boleh hardcoded di Flutter. Untuk production perlu backend function atau provider OTP resmi.

## Yang Masih Bisa Jadi Day 3

Day 3 bisa fokus membedah coding:

- kenapa ada service layer,
- kenapa pakai model,
- cara kerja RLS,
- alur insert request,
- cara QR dibuat dari data user,
- cara notifikasi disimpan dan dibaca,
- bagaimana refactor lanjutan ke feature-based folder penuh.
