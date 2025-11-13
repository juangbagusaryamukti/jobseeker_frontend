# 🧪 API Testing Examples

## Test dengan Thunder Client / Postman

### Login Request

**Method:** POST  
**URL:** `https://jobseeker-database.vercel.app/api/auth/login`  
**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "email": "hrdtelkom@gmail.com",
  "password": "12345678"
}
```

### Expected Response (Success)

**Status Code:** 200

```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGQwYTU0OTVmNGZiMDJhMmE1OWNkMTMiLCJpYXQiOjE3NDYwMDAwMDAsImV4cCI6MTc0NjA4NjQwMH0.example_signature",
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

### Expected Response (Failed)

**Status Code:** 401 atau 400

```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

## Test dengan cURL

### Login Success
```bash
curl -X POST https://jobseeker-database.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hrdtelkom@gmail.com","password":"12345678"}'
```

### Login Failed (Wrong Password)
```bash
curl -X POST https://jobseeker-database.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hrdtelkom@gmail.com","password":"wrongpassword"}'
```

## Test Credentials

| Email | Password | Expected Result |
|-------|----------|----------------|
| hrdtelkom@gmail.com | 12345678 | ✅ Success |
| butuhkerja@gmail.com | wrongpass | ❌ Failed |
| invalid@email.com | 12345678 | ❌ Failed |

## Debugging Tips

1. **Check Network Connection**
   - Pastikan device/emulator terhubung internet
   - Test API dengan browser/Postman terlebih dahulu

2. **Check Response**
   - Lihat console log di Flutter untuk response detail
   - Gunakan `debugPrint(response.body)` di auth_service.dart

3. **Common Errors**
   - `SocketException`: No internet connection
   - `FormatException`: Invalid JSON response
   - `TimeoutException`: API too slow or unreachable

## Integration Test di Flutter

Tambahkan di `login_view.dart` untuk debugging:

```dart
// Di fungsi _handleLogin, setelah panggil API
debugPrint('Response: ${result.toString()}');
```

Atau tambahkan di `auth_service.dart`:

```dart
// Di fungsi loginUser, setelah dapat response
debugPrint('Status Code: ${response.statusCode}');
debugPrint('Response Body: ${response.body}');
```
