# 🔐 Login Implementation Documentation

## 📁 Struktur File

```
lib/
├── models/
│   ├── user_model.dart              # Model data user
│   └── login_response_model.dart    # Model response login
├── services/
│   └── auth_service.dart            # Service untuk autentikasi
└── views/
    └── auth/
        └── login_view.dart          # UI halaman login
```

## 🔗 API Endpoint

**URL:** `POST https://jobseeker-database.vercel.app/api/auth/login`

**Request Body:**
```json
{
  "email": "hrdtelkom@gmail.com",
  "password": "12345678"
}
```

**Response (Success):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "68d0a5495f4fb02a2a59cd13",
    "name": "User Butuh Kerja",
    "email": "butuhkerja@gmail.com",
    "role": "Society",
    "isProfileComplete": true
  },
  "message": "Login successful"
}
```

**Response (Failed):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

## 📦 Dependencies

Tambahkan di `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.2
```

Jalankan:
```bash
flutter pub get
```

## 🚀 Cara Menggunakan

### 1. Navigasi ke Halaman Login

Di `main.dart`, route sudah ditambahkan:
```dart
routes: {
  '/login': (context) => LoginView(),
}
```

Untuk navigasi dari halaman lain:
```dart
Navigator.pushNamed(context, '/login');
```

### 2. Test Login

Gunakan credentials berikut untuk testing:
- **Email:** `hrdtelkom@gmail.com`
- **Password:** `12345678`

### 3. Setelah Login Berhasil

Token akan otomatis disimpan di SharedPreferences dengan key `"token"`.

Di file `login_view.dart` baris 68, ada komentar:
```dart
// TODO: Navigate to home screen
// Navigator.pushReplacementNamed(context, '/home');
```

Uncomment dan sesuaikan dengan route home screen Anda.

## 🔧 Fitur yang Sudah Diimplementasikan

✅ Form login dengan email & password  
✅ Show/hide password  
✅ Loading indicator saat proses login  
✅ SnackBar untuk menampilkan pesan sukses/error  
✅ Menyimpan token ke SharedPreferences  
✅ Error handling untuk network error  
✅ Disable input saat loading  
✅ Validasi input tidak boleh kosong  

## 📝 Fungsi Tambahan di AuthService

### Cek Status Login
```dart
final authService = AuthService();
bool isLoggedIn = await authService.isLoggedIn();
```

### Ambil Token
```dart
String? token = await authService.getToken();
```

### Logout
```dart
await authService.logout();
```

## 🎨 Customisasi UI

File `login_view.dart` menggunakan UI sederhana. Anda bisa customize:
- Warna button di `ElevatedButton.styleFrom()`
- Styling text di `TextStyle()`
- Layout di `Column` widget
- Tambahkan logo atau gambar

## 🐛 Troubleshooting

### Error: "SocketException"
- Pastikan device/emulator terhubung ke internet
- Cek URL API sudah benar

### Error: "FormatException"
- Response dari API tidak sesuai format JSON
- Cek response API menggunakan Postman/Thunder Client

### Token tidak tersimpan
- Pastikan SharedPreferences sudah di-initialize
- Cek permission di AndroidManifest.xml (untuk Android)

## 📱 Testing

1. Run aplikasi: `flutter run`
2. Navigasi ke `/login`
3. Masukkan credentials test
4. Klik tombol Login
5. Lihat SnackBar untuk pesan sukses/error
6. Check console untuk debug print user data

## 🔄 Next Steps

1. Buat halaman home screen
2. Uncomment navigasi ke home di `login_view.dart`
3. Implementasi auto-login (cek token saat app start)
4. Tambahkan halaman register
5. Implementasi refresh token
6. Tambahkan forgot password

---

**Created:** 2025-10-05  
**API:** https://jobseeker-database.vercel.app
