# 🚀 Adım Adım Ubuntu Sunucu Kurulumu

## Sunucu Bilgileri
- **IP**: 124.243.177.173
- **Kullanıcı**: root
- **Şifre**: Kenan_avc_4455
- **Açık Portlar**: 22, 80, 8080

---

## Yöntem 1: Otomatik PowerShell Script'i (Önerilen) ⚡

### Adım 1: PowerShell Script'ini Çalıştır

PowerShell'i **Yönetici Olarak** açın ve şu komutu çalıştırın:

```powershell
cd "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya\deployment"
.\install-remote.ps1
```

Script sizden 2 kez şifre isteyecek:
1. Dosya yüklemesi için (SCP)
2. Kurulum için (SSH)

Her seferinde şifreyi girin: `Kenan_avc_4455`

Script otomatik olarak:
- ✅ Projeyi ZIP'ler ve sunucuya yükler
- ✅ Node.js ve Python'u kurar
- ✅ Tüm bağımlılıkları yükler
- ✅ Systemd servisini oluşturur
- ✅ Servisi başlatır
- ✅ Port 8080'de çalışmaya başlar

---

## Yöntem 2: Manuel Kurulum (Adım Adım) 📋

### Adım 1: Sunucuya Bağlan

PowerShell'de:
```powershell
ssh root@124.243.177.173
```

Şifre: `Kenan_avc_4455`

### Adım 2: Proje Dizinini Oluştur

```bash
mkdir -p /opt/posture-detection
cd /opt/posture-detection
```

### Adım 3: Dosyaları Yükle

**YÖNTEM A: Windows'tan SCP ile** (Yeni bir PowerShell penceresi açın)

```powershell
# Backend dosyalarını yükle
scp -r "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya\backend" root@124.243.177.173:/opt/posture-detection/

# Deployment dosyalarını yükle
scp -r "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya\deployment" root@124.243.177.173:/opt/posture-detection/
```

**YÖNTEM B: WinSCP veya FileZilla Kullan**
1. WinSCP'yi aç
2. Host: `124.243.177.173`, User: `root`, Password: `Kenan_avc_4455`
3. Backend ve deployment klasörlerini `/opt/posture-detection/` dizinine sürükle

### Adım 4: Node.js Kur (Sunucuda)

```bash
# Node.js repository ekle
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Node.js kur
apt-get install -y nodejs

# Versiyonu kontrol et
node --version
npm --version
```

### Adım 5: Python Kur (Sunucuda)

```bash
# Python ve pip kur
apt-get update
apt-get install -y python3 python3-pip

# Versiyon kontrol
python3 --version
pip3 --version
```

### Adım 6: Backend Bağımlılıklarını Yükle

```bash
cd /opt/posture-detection/backend

# Node.js bağımlılıkları
npm install --production

# Python bağımlılıkları
pip3 install -r requirements.txt
```

### Adım 7: Environment Dosyası Oluştur

```bash
cd /opt/posture-detection/backend
nano .env
```

İçeriğe şunu yapıştır:
```env
NODE_ENV=production
PORT=8080
JWT_SECRET=super-secret-key-change-this-in-production
MONGODB_URI=mongodb://localhost:27017/posture_detection
```

`Ctrl+X`, `Y`, `Enter` ile kaydet.

### Adım 8: Systemd Servis Dosyası Oluştur

```bash
nano /etc/systemd/system/posture-detection.service
```

İçeriğe şunu yapıştır:
```ini
[Unit]
Description=Posture Detection Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/posture-detection/backend
Environment="NODE_ENV=production"
Environment="PORT=8080"
ExecStart=/usr/bin/node /opt/posture-detection/backend/src/server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=posture-detection

[Install]
WantedBy=multi-user.target
```

`Ctrl+X`, `Y`, `Enter` ile kaydet.

### Adım 9: Servisi Aktif Et

```bash
# Systemd'yi yenile
systemctl daemon-reload

# Servisi otomatik başlatmayı aktif et
systemctl enable posture-detection.service

# Servisi başlat
systemctl start posture-detection.service

# Durumu kontrol et
systemctl status posture-detection.service
```

Yeşil "active (running)" yazısını görmelisiniz! ✅

### Adım 10: Port Kontrolü

```bash
# Port 8080 dinleniyor mu?
netstat -tuln | grep :8080

# Veya
ss -tuln | grep :8080
```

Output'ta `:8080` görmelisiniz.

### Adım 11: Test Et

```bash
# Sunucunun içinden test
curl http://localhost:8080

# Dışarıdan test (Windows PowerShell'den)
curl http://124.243.177.173:8080
```

---

## 🔍 Kontrol ve Yönetim Komutları

### Servis Durumu
```bash
systemctl status posture-detection
```

### Servisi Yeniden Başlat
```bash
systemctl restart posture-detection
```

### Servisi Durdur
```bash
systemctl stop posture-detection
```

### Canlı Logları İzle
```bash
journalctl -u posture-detection -f
```

### Son 100 Log Satırı
```bash
journalctl -u posture-detection -n 100
```

### Hata Logları
```bash
journalctl -u posture-detection -p err
```

### Servis Kaç Kez Yeniden Başladı?
```bash
systemctl show posture-detection -p NRestarts
```

---

## 🔥 Sorun Giderme

### Servis başlamıyorsa:

```bash
# Logları detaylı incele
journalctl -u posture-detection -n 50 --no-pager

# Node.js yolu doğru mu?
which node

# Manuel çalıştırıp hatayı gör
cd /opt/posture-detection/backend
node src/server.js
```

### Port 8080 zaten kullanılıyorsa:

```bash
# Hangi process kullanıyor?
lsof -i :8080

# Process'i öldür
kill -9 <PID>

# Veya hepsini öldür
lsof -ti:8080 | xargs kill -9
```

### MongoDB hatası alıyorsanız:

```bash
# MongoDB kur
apt-get install -y mongodb

# Başlat
systemctl start mongodb
systemctl enable mongodb
```

### Bağımlılık hatası alıyorsanız:

```bash
cd /opt/posture-detection/backend

# Node modüllerini temizle ve yeniden yükle
rm -rf node_modules package-lock.json
npm install --production

# Python paketlerini yeniden yükle
pip3 install -r requirements.txt --force-reinstall
```

---

## 📊 Port ve Güvenlik Ayarları

### UFW Güvenlik Duvarı (Varsa)

```bash
# UFW durumunu kontrol et
ufw status

# Portları aç
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 8080/tcp  # Backend API

# UFW'yi aktif et (dikkat: SSH bağlantınız kopmaz)
ufw enable
```

### Nginx Reverse Proxy (Opsiyonel - Port 80'e yönlendirme)

```bash
# Nginx kur
apt-get install -y nginx

# Config oluştur
nano /etc/nginx/sites-available/posture-detection
```

İçerik:
```nginx
server {
    listen 80;
    server_name 124.243.177.173;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```bash
# Siteyi aktif et
ln -s /etc/nginx/sites-available/posture-detection /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default  # Varsayılan siteyi kaldır
nginx -t  # Config testi
systemctl restart nginx
```

Artık `http://124.243.177.173` adresinden de erişebilirsiniz (port belirtmeden).

---

## ✅ Başarı Kriterleri

Kurulum başarılı ise:
- ✅ `systemctl status posture-detection` komutu "active (running)" gösterir
- ✅ `netstat -tuln | grep :8080` komutu portu gösterir
- ✅ `curl http://localhost:8080` yanıt verir
- ✅ `curl http://124.243.177.173:8080` (dışarıdan) yanıt verir
- ✅ Loglar hatasız akar: `journalctl -u posture-detection -f`

---

## 🎯 Güncelleme Yaparken

```bash
# 1. Sunucuya bağlan
ssh root@124.243.177.173

# 2. Servisi durdur
systemctl stop posture-detection

# 3. Yeni dosyaları yükle (Windows'tan SCP ile)

# 4. Bağımlılıkları güncelle
cd /opt/posture-detection/backend
npm install --production
pip3 install -r requirements.txt

# 5. Servisi başlat
systemctl start posture-detection

# 6. Durumu kontrol et
systemctl status posture-detection
journalctl -u posture-detection -f
```

---

## 📞 Yardım

Herhangi bir sorun yaşarsanız:
1. Logları kontrol edin: `journalctl -u posture-detection -n 100`
2. Manuel çalıştırın: `cd /opt/posture-detection/backend && node src/server.js`
3. Port kontrolü: `netstat -tuln | grep :8080`
4. Process kontrolü: `ps aux | grep node`

Başarılar! 🚀
