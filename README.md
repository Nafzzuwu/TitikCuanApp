# TitikCuan: Sistem Informasi Manajemen Penjualan UMKM Berbasis Mobile dengan Analisis Lokasi Transaksi

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/Flutter-Dart-blue?style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Backend-Node.js%20%7C%20Express.js-darkgreen?style=for-the-badge&logo=node.js" alt="Backend" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL-blue?style=for-the-badge&logo=postgresql" alt="PostgreSQL" />
</p>

## 📌 Tentang Project
**TitikCuan** adalah sistem *Point of Sale* (POS) pintar berbasis *mobile* yang dirancang khusus untuk membantu pelaku UMKM berpindah atau dinamis (seperti pedagang keliling, *food truck*, hingga gerai *pop-up*). 

Aplikasi ini tidak hanya memodernisasi pencatatan transaksi manual menggunakan pemindai kamera ponsel, tetapi juga memanfaatkan sensor GPS untuk memetakan koordinat setiap transaksi. Data spasial tersebut kemudian dikelola untuk divisualisasikan menjadi **Sales Hotspot Heatmap**, sehingga pedagang dapat mengidentifikasi area atau rute penjualan dengan daya beli tertinggi secara presisi di masa depan.

Project ini dikembangkan sebagai bagian dari mata kuliah **Pemrograman Berbasis Mobile**, Program Studi Teknologi Informasi, Fakultas Ilmu Komputer, **Universitas Jember (2026)**.

---

## 🚀 Fitur Utama
1. **Smart Barcode Checkout (Sensor: Kamera)**
   Integrasi kamera perangkat menggunakan library `mobile_scanner` untuk membaca barcode produk (QR Code, Code 128, EAN-13) secara *real-time*. Sistem otomatis mencocokkan kode dengan database untuk mempercepat proses *checkout* tanpa input manual.
   
2. **Sales Hotspot Mapping (Sensor: GPS)**
   Merekam koordinat geografis (*latitude* dan *longitude*) secara otomatis begitu transaksi berhasil diselesaikan. Data ini dipetakan ke dalam bentuk grafik *heatmap* (peta panas historis) untuk mempermudah penentuan rute dagang yang paling menguntungkan.

3. **Real-time Stock Alert dengan Geo-Trigger (Sensor: GPS)**
   Manajemen stok pintar yang menyinkronkan jumlah produk dengan setiap transaksi. Ketika stok menyentuh batas minimum, sistem akan memberikan notifikasi peringatan yang dilengkapi informasi lokasi terakhir (*geo-tagged stock alert*) untuk membantu analisis restock berbasis area.

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
Sistem TitikCuan dibangun menggunakan arsitektur 4 lapisan utama:
1. **Lapisan Mobile (Flutter/Android):** Mengatur UI/UX, memproses kamera untuk *scanning*, dan menangkap lokasi dari sensor GPS.
2. **Lapisan Backend (Node.js & Express.js):** Custom REST API yang menangani enkapsulasi logika bisnis dengan endpoint utama:
   * `POST /transaction` - Menyimpan data transaksi & koordinat GPS.
   * `GET /heatmap-data` - Mengambil data agregat lokasi spasial.
   * `GET` & `PUT /stock` - Sinkronisasi dan pembaruan stok.
3. **Lapisan Data (PostgreSQL):** Menyimpan tabel relasional terstruktur berupa data produk, stok, dan lokasi transaksi spasial.
4. **Lapisan Visualisasi:** Me-render data spasial menjadi gradasi warna berdasarkan kepadatan volume transaksi menggunakan `flutter_map`.

---

## ⚠️ Batasan Sistem
* Aplikasi dioptimalkan khusus untuk platform Android.
* Visualisasi peta panas bersifat historis (agregat data masa lalu), bukan pelacakan *real-time*.
* Metode pembayaran saat ini terbatas pada pencatatan transaksi tunai dan transfer maupun penggunaan QRIS; integrasi *payment gateway* di luar cakupan project.

---
<p align="center">Made with ❤️ - Teknologi Informasi Universitas Jember</p>