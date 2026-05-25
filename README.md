# TitikCuan: Sistem Informasi Manajemen Penjualan UMKM Berbasis Mobile dengan Analisis Lokasi Transaksi

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/Flutter-Dart-blue?style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Backend-Node.js%20%7C%20Express.js-darkgreen?style=for-the-badge&logo=node.js" alt="Backend" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL-blue?style=for-the-badge&logo=postgresql" alt="PostgreSQL" />
</p>

## 📌 Tentang Project
[cite_start]**TitikCuan** adalah sistem *Point of Sale* (POS) pintar berbasis *mobile* yang dirancang khusus untuk membantu pelaku UMKM berpindah atau dinamis (seperti pedagang keliling, *food truck*, hingga gerai *pop-up*)[cite: 16, 19]. 

[cite_start]Aplikasi ini tidak hanya memodernisasi pencatatan transaksi manual menggunakan pemindai kamera ponsel, tetapi juga memanfaatkan sensor GPS untuk memetakan koordinat setiap transaksi[cite: 20]. [cite_start]Data spasial tersebut kemudian dikelola untuk divisualisasikan menjadi **Sales Hotspot Heatmap**, sehingga pedagang dapat mengidentifikasi area atau rute penjualan dengan daya beli tertinggi secara presisi di masa depan[cite: 21].

[cite_start]Project ini dikembangkan sebagai bagian dari mata kuliah **Pemrograman Berbasis Mobile**, Program Studi Teknologi Informasi, Fakultas Ilmu Komputer, **Universitas Jember (2026)**[cite: 7, 8, 9, 10, 11].

---

## 👥 Anggota Kelompok 8
* [cite_start]**Nafariel Dwi Ambariyono** (242410102071) 
* [cite_start]**Muhammad Rafli Hidayatullah** (242410102082) 
* [cite_start]**Maulana Irfanhaqi** (242410102042) 

---

## 🚀 Fitur Utama
1. [cite_start]**Smart Barcode Checkout (Sensor: Kamera)** [cite: 52]
   [cite_start]Integrasi kamera perangkat menggunakan library `mobile_scanner` untuk membaca barcode produk (QR Code, Code 128, EAN-13) secara *real-time*[cite: 39, 54]. [cite_start]Sistem otomatis mencocokkan kode dengan database untuk mempercepat proses *checkout* tanpa input manual[cite: 47, 54].
   
2. [cite_start]**Sales Hotspot Mapping (Sensor: GPS)** [cite: 56]
   [cite_start]Merekam koordinat geografis (*latitude* dan *longitude*) secara otomatis begitu transaksi berhasil diselesaikan[cite: 49]. [cite_start]Data ini dipetakan ke dalam bentuk grafik *heatmap* (peta panas historis) untuk mempermudah penentuan rute dagang yang paling menguntungkan[cite: 57, 59, 60].

3. [cite_start]**Real-time Stock Alert dengan Geo-Trigger (Sensor: GPS)** [cite: 61]
   [cite_start]Manajemen stok pintar yang menyinkronkan jumlah produk dengan setiap transaksi[cite: 62]. [cite_start]Ketika stok menyentuh batas minimum, sistem akan memberikan notifikasi peringatan yang dilengkapi informasi lokasi terakhir (*geo-tagged stock alert*) untuk membantu analisis restock berbasis area[cite: 63, 64].

---

## 🛠️ Teknologi yang Digunakan
| Komponen | Teknologi |
| --- | --- |
| **Platform Mobile** | Flutter (Dart) Android |
| **Pemindai Barcode** | Library `mobile_scanner` |
| **Sensor Lokasi** | GPS via `geolocator` |
| **Backend / API** | Node.js + Express.js (JavaScript) |
| **Database** | PostgreSQL |
| **Visualisasi Peta** | `flutter_map` + heatmap layer |
| **Komunikasi Data** | REST API (HTTP/JSON) |
| **State Management**| Provider / Riverpod |

---

## 🏗️ Arsitektur Sistem
[cite_start]Sistem TitikCuan dibangun menggunakan arsitektur 4 lapisan utama[cite: 68]:
1. [cite_start]**Lapisan Mobile (Flutter/Android):** Mengatur UI/UX, memproses kamera untuk *scanning*, dan menangkap lokasi dari sensor GPS[cite: 70, 71].
2. [cite_start]**Lapisan Backend (Node.js & Express.js):** Custom REST API yang menangani enkapsulasi logika bisnis dengan endpoint utama[cite: 41, 72]:
   * [cite_start]`POST /transaction` - Menyimpan data transaksi & koordinat GPS[cite: 72].
   * [cite_start]`GET /heatmap-data` - Mengambil data agregat lokasi spasial[cite: 72].
   * [cite_start]`GET` & `PUT /stock` - Sinkronisasi dan pembaruan stok[cite: 72].
3. [cite_start]**Lapisan Data (PostgreSQL):** Menyimpan tabel relasional terstruktur berupa data produk, stok, dan lokasi transaksi spasial[cite: 41, 74, 75].
4. [cite_start]**Lapisan Visualisasi:** Me-render data spasial menjadi gradasi warna berdasarkan kepadatan volume transaksi menggunakan `flutter_map`[cite: 76, 77].

---

## ⚠️ Batasan Sistem
* [cite_start]Aplikasi dioptimalkan khusus untuk platform Android[cite: 38].
* [cite_start]Visualisasi peta panas bersifat historis (agregat data masa lalu), bukan pelacakan *real-time*[cite: 42].
* [cite_start]Metode pembayaran saat ini terbatas pada pencatatan transaksi tunai (*cash*); integrasi *payment gateway* di luar cakupan project[cite: 42, 43].

---
<p align="center">Made with ❤️ - Teknologi Informasi Universitas Jember</p>