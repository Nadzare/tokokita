# tokokita

**Tugas 8 - Pertemuan 10**

**Nama** : Nadzare Kafah Alfatiha  
**NIM** : H1D023014  
**Shift** : A >> F

---

**Deskripsi Singkat**

`tokokita` adalah aplikasi mobile sederhana berbasis Flutter yang mengimplementasikan fitur CRUD (Create, Read, Update, Delete) untuk data produk dan otentikasi pengguna (registrasi & login). UI telah dimodifikasi dengan nuansa orange dan icon modern.

---

**Penjelasan Sistem**

- **Frontend (Flutter)** - folder `lib/`:
	- UI: `lib/ui/` — `login_page.dart`, `registrasi_page.dart`, `produk_page.dart`, `produk_form.dart`, `produk_detail.dart`.
	- Model: `lib/model/` — `login.dart`, `registrasi.dart`, `produk.dart` (mengandung `fromJson` factory untuk parsing respons API).
	- `main.dart` menginisialisasi `MaterialApp` dan theme global.

- **Backend (opsional)** - CodeIgniter 4 (direkomendasikan oleh modul). Endpoint yang diperlukan:
	- `/registrasi`, `/login` dan group `/produk` (create, read, update, delete).

---

**Alur Sistem (Flow & Penjelasan Kode)**

1. **Registrasi**
	 - Halaman: `registrasi_page.dart` (AppBar: "Registrasi Kafah").
	 - Field: `nama`, `email`, `password`, `konfirmasi password` — setiap field menggunakan `TextFormField` dengan `validator`.
	 - Setelah validasi sukses, UI saat ini menampilkan `SnackBar("Registrasi berhasil")` dan melakukan `Navigator.pop(context)` untuk kembali ke halaman login.

2. **Login**
	 - Halaman: `login_page.dart` (AppBar: "Login Kafah").
	 - Setelah validasi sukses, aplikasi melakukan `Navigator.pushReplacement(...)` ke `ProdukPage()` agar user langsung masuk ke halaman list produk.
	 - Jika terintegrasi API, respons login di-parse oleh `Login.fromJson(...)` dan token dapat disimpan (contoh: `shared_preferences`) untuk otorisasi selanjutnya.

3. **List Produk**
	 - Halaman: `produk_page.dart` (AppBar: "List Produk Kafah").
	 - Menampilkan list produk (sekarang dummy) menggunakan `ListView` dan widget `ItemProduk`.
	 - Tombol `+` membuka `ProdukForm` untuk menambah data.

4. **Tambah / Ubah Produk**
	 - Halaman: `produk_form.dart` — dinamis: jika `widget.produk != null` → mode Ubah (judul "UBAH PRODUK KAFAH" dan field terisi), jika `null` → mode Tambah (judul "TAMBAH PRODUK KAFAH").
	 - Validasi tiap field, lalu tampilkan SnackBar dan `Navigator.pop(context)`.

5. **Detail / Hapus Produk**
	 - Halaman: `produk_detail.dart` (AppBar: "Detail Produk Kafah").
	 - Menampilkan detail, tombol `EDIT` membuka `ProdukForm(produk: ...)`, tombol `DELETE` menampilkan dialog konfirmasi lalu menghapus (UI sekarang hanya menunjukkan SnackBar dan kembali ke list).

**Penjelasan singkat potongan kode penting**

- Contoh factory pada `lib/model/login.dart` (parse JSON):

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

Penjelasan: jika API mengembalikan struktur nested (`data.token` dan `data.user`), factory ini mengekstrak token dan informasi user. Jika API mengembalikan struktur lain, sesuaikan factory.

- Validasi form: tiap `TextFormField` memiliki `validator` yang mengembalikan pesan error bila input tidak sesuai (mis. panjang password minimal, email invalid, konfirmasi password tidak cocok).

- Navigasi: `Navigator.push(...)`, `Navigator.pushReplacement(...)`, dan `Navigator.pop(...)` dipakai untuk berpindah antar halaman sesuai alur.

---

**Dokumentasi Output (Screenshots)**

### 1. Registrasi
![Registrasi](https://github.com/Nadzare/tokokita/blob/main/docs/registrasi.png)

### 2. Login
![Login](https://github.com/Nadzare/tokokita/blob/main/docs/login.png)

### 3. List Produk
![List Produk](https://github.com/Nadzare/tokokita/blob/main/docs/list.png)

### 4. Drawer / Side Menu
![Side Menu](https://github.com/Nadzare/tokokita/blob/main/docs/side.png)

### 5. Tambah Produk
![Tambah Produk](https://github.com/Nadzare/tokokita/blob/main/docs/tambah.png)

### 6. Edit Produk
![Edit Produk](https://github.com/Nadzare/tokokita/blob/main/docs/edit.png)

### 7. Detail Produk
![Detail Produk](https://github.com/Nadzare/tokokita/blob/main/docs/detail.png)

> Pastikan file-file gambar berada di folder `docs/` agar screenshot tampil pada README GitHub.---

**Cara Menjalankan (singkat)**

1. Buka terminal pada folder project (`d:\setupflutter\tokokita`).
2. Jalankan:

```bash
flutter pub get
flutter run
```

---

Jika Anda ingin, saya bisa:

- Memeriksa folder `docs/` dan menambahkan gambar yang hilang atau memperbaiki path.  
- Menambahkan diagram alur (file PNG) dan memasukkannya ke README.  
- Menyertakan contoh panggilan HTTP (menggunakan `http` package) untuk integrasi ke backend.

Beritahu saya langkah mana yang mau saya lanjutkan.
