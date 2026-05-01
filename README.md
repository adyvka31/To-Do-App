# 📸 Attendance App 📸

> Aplikasi absensi digital modern yang mengintegrasikan fitur kamera dan Firebase untuk pencatatan kehadiran yang akurat dan efisien.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

## 📱 Tentang Proyek

Attendance App adalah aplikasi mobile lintas platform yang dibangun menggunakan Flutter. Proyek ini dirancang untuk mendigitalisasi dan menyederhanakan proses absensi. Dengan memanfaatkan Firebase sebagai infrastruktur *backend* dan akses kamera *real-time*, aplikasi ini memastikan setiap data kehadiran diverifikasi dan dikelola secara aman.

## ✨ Fitur Utama

* **🔐 Sistem Autentikasi Komprehensif:** Mengelola akses pengguna melalui layar Login, Registrasi, dan Lupa Password menggunakan Firebase Authentication.
* **📷 Verifikasi dengan Kamera:** Layar khusus (`camera_screen`) yang memungkinkan pengguna mengambil foto secara langsung sebagai bukti autentik saat melakukan absensi.
* **🎨 UI/UX Modern & Dinamis:** Dibangun dengan integrasi ilustrasi yang memanjakan mata, tipografi konsisten (Font Poppins), serta kemampuan ubah tema melalui `theme_controller`.
* **☁️ Cloud-Ready Backend:** Penanganan data yang asinkron dan *real-time* berkat koneksi penuh dengan ekosistem Firebase.

## 🛠️ Teknologi yang Digunakan

* **Framework:** Flutter (Dart)
* **Backend:** Firebase (Authentication & Core Services)
* **Integrasi Native:** Camera Plugin untuk akses *hardware* perangkat.
* **Arsitektur:** Pendekatan berbasis Controller untuk pemisahan *logic* (tema & layar).

## 🚀 Cara Instalasi & Penggunaan

1.  **Clone repositori ini:**
    ```bash
    git clone https://github.com/adyvka31/attendance-app.git
    ```
2.  **Pindah ke direktori proyek:**
    ```bash
    cd attendance-app
    ```
3.  **Instal semua dependensi:**
    ```bash
    flutter pub get
    ```
4.  **Konfigurasi Firebase:**
    * Pastikan Anda menyesuaikan atau menambahkan `google-services.json` (untuk Android) dan `GoogleService-Info.plist` (untuk iOS) jika ingin menyambungkannya ke *environment* Firebase milik Anda sendiri.
5.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---
*Dibangun untuk menyempurnakan portofolio eksplorasi fungsionalitas hardware dan cloud backend menggunakan Flutter.*
