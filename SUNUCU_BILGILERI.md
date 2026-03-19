# SpineAI Proje Bilgileri

## Sunucu Bilgileri
- **IP Adresi:** 124.243.177.173
- **Web URL:** http://124.243.177.173:8080
- **SSH Kullanıcı:** root

## Proje Konumları (Sunucuda)
- **Ana Dizin:** `/snap/SpineAI/SpineAI web/`
- **Backend:** `/snap/SpineAI/SpineAI web/backend/`
- **Frontend:** `/snap/SpineAI/SpineAI web/frontend/dist/`
- **AI Modeller:** Backend dizininde (`best.onnx`, `best postur.onnx`)

## Giriş Bilgileri
- **Email:** oktarnisa23@gmail.com
- **Şifre:** 762017Nisa_@

## Kullanılan Servisler
- **MongoDB:** Port 27017 (Veritabanı)
- **Node.js Backend:** Port 8080 (API + Frontend)
- **Systemd Servisi:** posture-detection

## Projeyi Başlatma

### 1. Sunucu Durumunu Kontrol Et
```powershell
.\deployment\start-server.ps1
```

### 2. Servisler Çalışmıyorsa Başlat
```powershell
.\deployment\restart-server.ps1
```

### 3. Manuel Komutlar
```powershell
# Sunucuya bağlan
ssh root@124.243.177.173

# Servisleri kontrol et
systemctl status mongodb posture-detection

# Servisleri başlat
systemctl start mongodb
systemctl start posture-detection

# Servisleri durdur
systemctl stop posture-detection

# Logları görüntüle
journalctl -u posture-detection -f
```

## Veritabanı
- **MongoDB Veritabanı:** spineai
- **Koleksiyonlar:** users, analyses
- **Veri Konumu:** `/var/lib/mongodb/`

## Yedekleme Konumları
- **Eski Dizin:** `/opt/posture-detection/`
- **Yeni Dizin:** `/snap/SpineAI/SpineAI web/`

## Sorun Giderme

### Servis Çalışmıyorsa
```powershell
ssh root@124.243.177.173 "systemctl restart posture-detection"
```

### Logları Kontrol Et
```powershell
ssh root@124.243.177.173 "journalctl -u posture-detection -n 50"
```

### Python Hatası
Sistem kütüphaneleri kurulu: libgl1-mesa-glx, libglib2.0-0

## Port Bilgileri
- **8080:** Web arayüzü ve API
- **27017:** MongoDB

## Güvenlik
- Firewall kuralları: 8080 portuna dışarıdan erişim açık
- MongoDB: Sadece localhost'tan erişilebilir
