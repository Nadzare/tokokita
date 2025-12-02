# tokokita
**Tugas 8 - Pertemuan 10** 
**Tugas 9 - Pertemuan 11**  
*Update: API Integration with Backend*

**Nama** : Nadzare Kafah Alfatiha  
**NIM** : H1D023014  
**Shift** : A >> F

---

**Deskripsi Singkat**

`tokokita` adalah aplikasi mobile berbasis Flutter yang mengimplementasikan fitur CRUD (Create, Read, Update, Delete) untuk data produk dengan integrasi API Backend (CodeIgniter 4). Aplikasi ini memiliki fitur otentikasi pengguna (registrasi & login) dengan token-based authentication menggunakan Bearer Token. UI telah dimodifikasi dengan nuansa orange dan icon modern.

---

**Penjelasan Sistem**

- **Frontend (Flutter)** - folder `lib/`:
	- **UI**: `lib/ui/` — `login_page.dart`, `registrasi_page.dart`, `produk_page.dart`, `produk_form.dart`, `produk_detail.dart`.
	- **Model**: `lib/model/` — `login.dart`, `registrasi.dart`, `produk.dart` (mengandung `fromJson` factory untuk parsing respons API).
	- **BLoC**: `lib/bloc/` — `login_bloc.dart`, `registrasi_bloc.dart`, `logout_bloc.dart`, `produk_bloc.dart` (business logic untuk komunikasi API).
	- **Helpers**: `lib/helpers/` — `api.dart` (HTTP wrapper), `api_url.dart` (endpoint URLs), `user_info.dart` (token storage), `app_exception.dart` (custom exceptions).
	- **Widget**: `lib/widget/` — `success_dialog.dart`, `warning_dialog.dart` (dialog untuk notifikasi).
	- `main.dart` menginisialisasi `MaterialApp`, theme global, dan check token untuk routing otomatis (jika ada token → ProdukPage, jika tidak → LoginPage).

- **Backend** - CodeIgniter 4 REST API. Endpoint yang digunakan:
	- `POST /registrasi` - Register user baru
	- `POST /login` - Login user dan mendapatkan token
	- `GET /produk` - Get list produk (dengan Bearer Token)
	- `POST /produk` - Create produk baru (dengan Bearer Token)
	- `PUT /produk/{id}/update` - Update produk (dengan Bearer Token)
	- `DELETE /produk/{id}` - Delete produk (dengan Bearer Token)

---

**Arsitektur Aplikasi**

Aplikasi menggunakan **BLoC Pattern (Business Logic Component)** untuk memisahkan business logic dari UI:

```
UI Layer (Widgets) 
    ↕ 
BLoC Layer (API Calls) 
    ↕ 
Helper Layer (HTTP Wrapper, Token Storage) 
    ↕ 
Backend API (CodeIgniter 4)
```

**Flow Token Authentication:**
1. User login → API return token → Save to SharedPreferences
2. Setiap API call produk → Inject Bearer Token di header
3. User logout → Clear SharedPreferences → Redirect ke login

---

**Alur Sistem (Flow & Penjelasan Kode)**

### 1. **Registrasi**
- **Halaman**: `registrasi_page.dart` (AppBar: "Registrasi Kafah")
- **Field**: `nama`, `email`, `password`, `konfirmasi password` dengan validasi
- **Proses**:
  - User mengisi form → Validasi → Call `RegistrasiBloc.registrasi()`
  - BLoC hit API `POST /registrasi` dengan data form
  - Jika sukses → Tampilkan `SuccessDialog` → Redirect ke login
  - Jika error → Tampilkan `WarningDialog` dengan pesan error
- **Loading State**: Button menampilkan `CircularProgressIndicator` saat proses berlangsung

### 2. **Login**
- **Halaman**: `login_page.dart` (AppBar: "Login Kafah")
- **Proses**:
  - User input email & password → Validasi → Call `LoginBloc.login()`
  - BLoC hit API `POST /login` → Terima response dengan token
  - Parse response dengan `Login.fromJson()` → Extract token & userID
  - Save token & userID ke SharedPreferences via `UserInfo()`
  - `Navigator.pushReplacement()` ke `ProdukPage()`
- **Auto Login**: Di `main.dart`, cek token saat app start → Jika ada token langsung ke ProdukPage

### 3. **List Produk**
- **Halaman**: `produk_page.dart` (AppBar: "List Produk Kafah")
- **Proses**:
  - Gunakan `FutureBuilder` untuk async data loading
  - Call `ProdukBloc.getProduks()` → Hit API `GET /produk` dengan Bearer Token
  - Parse response JSON array menjadi `List<Produk>`
  - Tampilkan di `ListView.builder` dengan widget `ItemProduk`
- **Loading State**: `CircularProgressIndicator` saat data loading
- **Drawer**: Menu logout yang call `LogoutBloc.logout()` → Clear SharedPreferences → Redirect ke login
- **Add Button**: Tombol `+` di AppBar untuk membuka `ProdukForm` mode tambah

### 4. **Tambah / Ubah Produk**
- **Halaman**: `produk_form.dart`
- **Dynamic Mode**:
  - Jika `widget.produk == null` → Mode Tambah ("TAMBAH PRODUK KAFAH", button "SIMPAN")
  - Jika `widget.produk != null` → Mode Ubah ("UBAH PRODUK KAFAH", button "UBAH", field auto-fill)
- **Proses Tambah**:
  - Validasi → Create `Produk` object dari input
  - Call `ProdukBloc.addProduk()` → Hit API `POST /produk` dengan Bearer Token
  - Jika sukses → `Navigator.pushAndRemoveUntil()` ke ProdukPage (refresh list)
  - Jika error → `WarningDialog`
- **Proses Ubah**:
  - Validasi → Create `Produk` object dengan ID existing
  - Call `ProdukBloc.updateProduk()` → Hit API `PUT /produk/{id}/update`
  - Jika sukses → Redirect ke ProdukPage
  - Jika error → `WarningDialog`

### 5. **Detail / Hapus Produk**
- **Halaman**: `produk_detail.dart` (AppBar: "Detail Produk Kafah")
- **Tampilan**: Info lengkap produk (kode, nama, harga) dengan icon
- **Tombol EDIT**: Buka `ProdukForm` dengan mode ubah (pass `produk` object)
- **Tombol DELETE**:
  - Tampilkan `AlertDialog` konfirmasi
  - Jika user confirm → Call `ProdukBloc.deleteProduk()` → Hit API `DELETE /produk/{id}`
  - Jika sukses → Redirect ke ProdukPage
  - Jika error → `WarningDialog`

---

**Penjelasan Detail Implementasi Kode**

### 1. Helper Layer

**`lib/helpers/api.dart`** - HTTP Wrapper dengan Bearer Token
```dart
class Api {
  Future<dynamic> post(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    final response = await http.post(Uri.parse(url),
        body: data,
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    return _returnResponse(response);
  }
  
  Future<dynamic> put(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    final response = await http.put(
      Uri.parse(url),
      body: json.encode(data),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );
    return _returnResponse(response);
  }
  // ... method get, delete mirip
}
```
**Penjelasan:**
- Inject Bearer Token otomatis di setiap request dari SharedPreferences
- Method PUT menggunakan `json.encode(data)` dengan header `Content-Type: application/json` agar backend CodeIgniter bisa membaca body request dengan benar
- Handle error dengan custom exception (400, 401, 403, 422, 500)
- Gunakan `http` package untuk HTTP calls

**`lib/helpers/api_url.dart`** - Centralized Endpoints dengan Koneksi Backend
```dart
class ApiUrl {
  static const String baseUrl = 'http://192.168.100.13:8080';
  static const String registrasi = baseUrl + '/registrasi';
  static const String login = baseUrl + '/login';
  static const String listProduk = baseUrl + '/produk';
  static const String createProduk = baseUrl + '/produk';
  
  static String updateProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }
  
  static String showProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }
  
  static String deleteProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }
}
```
**Penjelasan Koneksi dengan Backend CodeIgniter:**
- **Base URL**: `http://192.168.100.13:8080` adalah IP address laptop yang menjalankan backend CodeIgniter
- **Endpoint Mapping**:
  - `POST /registrasi` → Registrasi user baru ke database
  - `POST /login` → Autentikasi user, return JWT token
  - `GET /produk` → Mengambil semua data produk (memerlukan Bearer token)
  - `POST /produk` → Menambah produk baru (memerlukan Bearer token)
  - `PUT /produk/{id}` → Update produk berdasarkan ID (memerlukan Bearer token)
  - `DELETE /produk/{id}` → Hapus produk berdasarkan ID (memerlukan Bearer token)

**Catatan Penting untuk Base URL:**
- **Android Emulator**: Gunakan `http://10.0.2.2:8080` (10.0.2.2 adalah alias untuk localhost host machine)
- **Browser/Web**: Gunakan `http://localhost:8080`
- **Device Fisik**: Gunakan IP laptop di network yang sama (contoh: `http://192.168.100.13:8080`)
- Pastikan backend CodeIgniter sudah running dengan `php spark serve`

**`lib/helpers/user_info.dart`** - Token Storage
```dart
class UserInfo {
  Future setToken(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString("token", value);
  }
  
  Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token");
  }
  
  Future logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }
}
```
- Simpan token & userID di local storage (persisten)
- Method `logout()` clear semua data

### 2. BLoC Layer

**`lib/bloc/login_bloc.dart`**
```dart
class LoginBloc {
  static Future<Login> login({String? email, String? password}) async {
    String apiUrl = ApiUrl.login;
    var body = {"email": email, "password": password};
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return Login.fromJson(jsonObj);
  }
}
```
- Static method untuk call API
- Return model object `Login` yang sudah parsed

**`lib/bloc/produk_bloc.dart`**
```dart
class ProdukBloc {
  static Future<List<Produk>> getProduks() async {
    String apiUrl = ApiUrl.listProduk;
    var response = await Api().get(apiUrl);
    var jsonObj = json.decode(response.body);
    List<dynamic> listProduk = (jsonObj as Map<String, dynamic>)['data'];
    List<Produk> produks = [];
    for (int i = 0; i < listProduk.length; i++) {
      produks.add(Produk.fromJson(listProduk[i]));
    }
    return produks;
  }
  
  static Future addProduk({Produk? produk}) async {
    String apiUrl = ApiUrl.createProduk;
    var body = {
      "kode_produk": produk!.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString()
    };
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return jsonObj['status'];
  }
  
  // updateProduk dan deleteProduk mirip
}
```

### 3. Model Layer

**`lib/model/login.dart`** - Parse nested JSON
```dart
factory Login.fromJson(Map<String, dynamic> obj) {
  return Login(
    code: obj['code'],
    status: obj['status'],
    token: obj['data']['token'],
    userID: obj['data']['user']['id'],
    userEmail: obj['data']['user']['email'],
  );
}
```
- Extract data dari struktur nested API response
- Jika struktur API berbeda, sesuaikan factory method

### 4. UI Integration

**`lib/ui/login_page.dart`** - Submit Login
```dart
void _submit() {
  setState(() { _isLoading = true; });
  
  LoginBloc.login(
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text
  ).then((value) async {
    if (value.code == 200) {
      await UserInfo().setToken(value.token.toString());
      await UserInfo().setUserID(int.parse(value.userID.toString()));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProdukPage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => WarningDialog(
          description: "Login gagal, silahkan coba lagi",
        )
      );
    }
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => WarningDialog(
        description: error.toString(),
      )
    );
  }).whenComplete(() {
    setState(() { _isLoading = false; });
  });
}
```
- Loading state dengan `_isLoading` boolean
- Save token setelah login sukses
- Error handling dengan dialog

**`lib/ui/produk_page.dart`** - FutureBuilder
```dart
FutureBuilder<List>(
  future: ProdukBloc.getProduks(),
  builder: (context, snapshot) {
    if (snapshot.hasError) print(snapshot.error);
    return snapshot.hasData
      ? ListProduk(list: snapshot.data)
      : const Center(child: CircularProgressIndicator());
  },
)
```
- Async data loading dengan loading indicator
- Auto rebuild saat data tersedia

---

**Dependencies yang Digunakan**

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.2.0              # HTTP client untuk API calls
  shared_preferences: ^2.2.2 # Local storage untuk token
```

Install dependencies:
```bash
flutter pub get
```

---

**Dokumentasi Output (Screenshots)**

### 1. Form Registrasi
![Form Registrasi](https://github.com/Nadzare/tokokita/blob/main/docs/fmregis.png)
*Halaman registrasi dengan field nama, email, password, dan konfirmasi password*

### 2. Popup Registrasi Berhasil
![Popup Registrasi](https://github.com/Nadzare/tokokita/blob/main/docs/popregis.png)
*Dialog sukses setelah registrasi berhasil, redirect ke halaman login*

### 3. Form Tambah Produk
![Form Tambah Produk](https://github.com/Nadzare/tokokita/blob/main/docs/fmtambah.png)
*Halaman untuk menambahkan produk baru dengan field kode, nama, dan harga*

### 4. Popup Tambah Produk Berhasil
![Popup Tambah](https://github.com/Nadzare/tokokita/blob/main/docs/poptambah.png)
*Dialog konfirmasi "Berhasil menambahkan produk!" setelah create berhasil*

### 5. Form Edit Produk
![Form Edit Produk](https://github.com/Nadzare/tokokita/blob/main/docs/fmedit.png)
*Halaman edit produk dengan field yang sudah terisi data existing*

### 6. Popup Edit Produk Berhasil
![Popup Edit](https://github.com/Nadzare/tokokita/blob/main/docs/popedit.png)
*Dialog konfirmasi "Berhasil mengubah produk!" setelah update berhasil*

### 7. Konfirmasi Delete Produk
![Konfirmasi Delete](https://github.com/Nadzare/tokokita/blob/main/docs/konfdel.png)
*Dialog konfirmasi sebelum menghapus produk - "Yakin ingin menghapus produk ini?"*

### 8. Popup Delete Produk Berhasil
![Popup Delete](https://github.com/Nadzare/tokokita/blob/main/docs/popdel.png)
*Dialog konfirmasi "Berhasil menghapus produk!" setelah delete berhasil*

> **Note**: Semua operasi CRUD (Create, Read, Update, Delete) dilengkapi dengan popup feedback untuk user experience yang lebih baik. Success dialog menggunakan `SuccessDialog` widget dengan callback untuk navigasi setelah user klik OK.

---

**Setup Backend API (CodeIgniter 4)**

1. Clone atau setup backend CodeIgniter 4 dengan endpoint:
   - `POST /registrasi` - body: `nama`, `email`, `password`
   - `POST /login` - body: `email`, `password` → return: `token`
   - `GET /produk` - header: `Authorization: Bearer {token}` → return: array produk
   - `POST /produk` - header: `Bearer token`, body: `kode_produk`, `nama_produk`, `harga`
   - `PUT /produk/{id}/update` - header: `Bearer token`, body: data produk
   - `DELETE /produk/{id}` - header: `Bearer token`

2. Jalankan backend di localhost (default port 8080):
   ```bash
   php spark serve
   ```

3. **Penting**: Base URL di Flutter menggunakan `10.0.2.2` untuk Android Emulator:
   - `10.0.2.2:8080` = localhost untuk emulator
   - Untuk device fisik, ganti dengan IP laptop di network yang sama (misal `192.168.1.100:8080`)
   - Edit `lib/helpers/api_url.dart` untuk mengubah base URL

---

**Cara Menjalankan Aplikasi Flutter**

1. **Setup Backend** (jika belum):
   ```bash
   cd /path/to/toko-api
   php spark serve
   ```

2. **Setup Flutter**:
   ```bash
   cd d:\setupflutter\tokokita
   flutter pub get
   ```

3. **Run di Android Emulator**:
   ```bash
   flutter run
   ```

4. **Test Flow**:
   - Registrasi user baru → Login → List produk (kosong/dari database)
   - Tambah produk → Lihat di list → Edit produk → Detail → Delete

---

**Troubleshooting**

### Error: Connection refused / Failed host lookup
- **Penyebab**: Backend tidak running atau base URL salah
- **Solusi**: 
  - Pastikan backend running di `php spark serve`
  - Cek `lib/helpers/api_url.dart` base URL:
    - Emulator: `http://10.0.2.2:8080/toko-api/public`
    - Device fisik: `http://192.168.x.x:8080/toko-api/public`

### Error: 401 Unauthorized
- **Penyebab**: Token expired atau tidak valid
- **Solusi**: Logout dan login ulang untuk refresh token

### Error: Unhandled Exception: FormatException
- **Penyebab**: Response API tidak sesuai dengan model factory
- **Solusi**: 
  - Print response di console: `print(response.body)`
  - Sesuaikan `fromJson()` factory dengan struktur API

---

**Fitur yang Sudah Diimplementasikan**

✅ Registrasi dengan validasi form  
✅ Login dengan token authentication  
✅ Auto login (cek token saat app start)  
✅ List produk dari API dengan loading state  
✅ Create produk baru dengan popup success  
✅ Update produk existing dengan popup success  
✅ Delete produk dengan konfirmasi dan popup success  
✅ Detail produk  
✅ Logout (clear token)  
✅ Bearer token injection otomatis  
✅ Error handling dengan custom dialog  
✅ Orange theme dengan modern icons  
✅ Loading indicators pada setiap async operation  
✅ Success dialog untuk semua operasi CRUD  
✅ PUT request dengan JSON encoding untuk kompatibilitas CodeIgniter  

---

**Perbaikan Khusus untuk Update Produk**

Masalah yang ditemui:
- Backend CodeIgniter tidak bisa membaca body dari PUT request dengan format form-data
- Data produk yang dikirim menjadi kosong (empty string dan harga 0)

Solusi yang diterapkan:
```dart
// api.dart - Method PUT
Future<dynamic> put(dynamic url, dynamic data) async {
  var token = await UserInfo().getToken();
  final response = await http.put(
    Uri.parse(url),
    body: json.encode(data),  // Encode data menjadi JSON
    headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",  // Set Content-Type
    },
  );
  return _returnResponse(response);
}
```

Dengan perubahan ini:
- Data dikirim dalam format JSON yang bisa dibaca CodeIgniter
- Header `Content-Type: application/json` memastikan backend parse body dengan benar
- Update produk berhasil dengan data lengkap  

---

**Struktur Folder Project**

```
tokokita/
├── lib/
│   ├── bloc/
│   │   ├── login_bloc.dart
│   │   ├── logout_bloc.dart
│   │   ├── produk_bloc.dart
│   │   └── registrasi_bloc.dart
│   ├── helpers/
│   │   ├── api.dart
│   │   ├── api_url.dart
│   │   ├── app_exception.dart
│   │   └── user_info.dart
│   ├── model/
│   │   ├── login.dart
│   │   ├── produk.dart
│   │   └── registrasi.dart
│   ├── ui/
│   │   ├── login_page.dart
│   │   ├── produk_detail.dart
│   │   ├── produk_form.dart
│   │   ├── produk_page.dart
│   │   └── registrasi_page.dart
│   ├── widget/
│   │   ├── success_dialog.dart
│   │   └── warning_dialog.dart
│   └── main.dart
├── android/
├── ios/
├── test/
├── docs/          # Screenshot untuk README
├── pubspec.yaml
└── README.md
```

---

**Changelog - Pertemuan 11 (API Integration)**

**Added:**
- BLoC layer untuk business logic (`login_bloc.dart`, `registrasi_bloc.dart`, `logout_bloc.dart`, `produk_bloc.dart`)
- Helper layer untuk API communication (`api.dart`, `api_url.dart`, `user_info.dart`, `app_exception.dart`)
- Widget layer untuk dialog (`success_dialog.dart`, `warning_dialog.dart`)
- Token-based authentication dengan Bearer Token
- SharedPreferences untuk local token storage
- Auto login feature (check token on app start)
- Loading indicators pada semua async operations
- Error handling dengan custom exceptions dan dialog

**Modified:**
- `main.dart`: Tambah isLogin() check untuk auto routing
- `login_page.dart`: Integrasi LoginBloc, save token, loading state
- `registrasi_page.dart`: Integrasi RegistrasiBloc dengan dialog
- `produk_page.dart`: FutureBuilder dengan ProdukBloc.getProduks()
- `produk_form.dart`: Integrasi addProduk() dan updateProduk()
- `produk_detail.dart`: Integrasi deleteProduk() dengan API
- All models: Factory fromJson() untuk parse API response

**Dependencies:**
- `http: ^1.2.0` - HTTP client
- `shared_preferences: ^2.2.2` - Local storage

---

**Kredit & Referensi**

- **Framework**: Flutter 
- **Backend**: CodeIgniter 4
- **Design Pattern**: BLoC (Business Logic Component)
- **Authentication**: Bearer Token with JWT
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences

---

**Kontributor**

Nadzare Kafah Alfatiha - H1D023014 - Shift A >> F

---

**Lisensi**

Project ini dibuat untuk keperluan tugas kuliah Pemrograman Mobile.
