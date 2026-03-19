# 🚀 Ubuntu Sunucuya Deployment Talimatları

## 📋 Sunucu Bilgileri
- **IP**: 124.243.177.173
- **Kullanıcı**: root
- **Açık Portlar**: 22, 80, 8080

## 1️⃣ SSH Bağlantısı

```bash
ssh root@124.243.177.173
# Şifre: Kenan_avc_4455
```

## 2️⃣ Proje Dosyalarını Sunucuya Yükleme

### Seçenek A: SCP ile Yükleme (Windows PowerShell'den)

```powershell
# Projenin bulunduğu dizinde
scp -r "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya" root@124.243.177.173:/opt/posture-detection
```

### Seçenek B: Git ile Yükleme (Sunucuda)

```bash
cd /opt
git clone <repository-url> posture-detection
cd posture-detection
```

### Seçenek C: Manuel Yükleme
1. Projenizi ZIP olarak sıkıştırın
2. WinSCP veya FileZilla gibi bir FTP istemcisi kullanın
3. Dosyaları `/opt/posture-detection` dizinine yükleyin

## 3️⃣ Otomatik Kurulum Script'i Çalıştırma

```bash
# Sunucuya bağlandıktan sonra
cd /opt/posture-detection/deployment
chmod +x setup-service.sh
./setup-service.sh
```

Bu script otomatik olarak:
- ✅ Node.js ve Python'u kurar
- ✅ Tüm bağımlılıkları yükler
- ✅ Systemd servisini oluşturur
- ✅ Servisi başlatır ve enable eder

## 4️⃣ Manuel Kurulum (Alternatif)

### Adım 1: Bağımlılıkları Yükle

```bash
# Node.js 18.x kurulumu
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Python ve pip
apt-get update
apt-get install -y python3 python3-pip python3-venv

# Backend bağımlılıkları
cd /opt/posture-detection/backend
npm install --production

# Python bağımlılıkları
pip3 install -r requirements.txt
```

### Adım 2: .env Dosyası Oluştur

```bash
cd /opt/posture-detection/backend
nano .env
```

İçeriği:
```env
NODE_ENV=production
PORT=8080
JWT_SECRET=your-super-secret-jwt-key-change-this
MONGODB_URI=mongodb://localhost:27017/posture_detection
```

### Adım 3: Servis Dosyasını Kopyala

```bash
cp /opt/posture-detection/deployment/posture-detection.service /etc/systemd/system/
```

### Adım 4: Servisi Aktifleştir

```bash
# Systemd'yi yeniden yükle
systemctl daemon-reload

# Servisi otomatik başlatmayı aktif et
systemctl enable posture-detection.service

# Servisi başlat
systemctl start posture-detection.service

# Durumu kontrol et
systemctl status posture-detection.service
```

## 5️⃣ Servis Yönetim Komutları

```bash
# Servis durumunu kontrol et
systemctl status posture-detection

# Servisi başlat
systemctl start posture-detection

# Servisi durdur
systemctl stop posture-detection

# Servisi yeniden başlat
systemctl restart posture-detection

# Servis loglarını görüntüle (canlı)
journalctl -u posture-detection -f

# Son 100 log satırını görüntüle
journalctl -u posture-detection -n 100

# Bugünkü logları görüntüle
journalctl -u posture-detection --since today
```

## 6️⃣ Port ve Güvenlik Duvarı Kontrolü

```bash
# Dinlenen portları kontrol et
netstat -tuln | grep LISTEN

# 8080 portunu kontrol et
netstat -tuln | grep :8080

# UFW güvenlik duvarı varsa
ufw status
ufw allow 8080/tcp
ufw allow 80/tcp
ufw allow 22/tcp
```

## 7️⃣ Nginx Reverse Proxy (Opsiyonel)

Port 80'den 8080'e yönlendirme için:

```bash
# Nginx kurulumu
apt-get install -y nginx

# Konfigürasyon dosyası oluştur
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
nginx -t
systemctl restart nginx
```

## 8️⃣ Sorun Giderme

### Servis başlamıyorsa:

```bash
# Hata loglarını kontrol et
journalctl -u posture-detection -n 50 --no-pager

# Node.js yolunu kontrol et
which node

# Çalışma dizinini kontrol et
ls -la /opt/posture-detection/backend

# Manuel olarak çalıştırıp hataları gör
cd /opt/posture-detection/backend
node src/server.js
```

### Port zaten kullanılıyorsa:

```bash
# 8080 portunu kullanan process'i bul
lsof -i :8080
# veya
netstat -tuln | grep :8080

# Process'i sonlandır
kill -9 <PID>
```

## 9️⃣ Test

```bash
# Sunucunun kendisinden test
curl http://localhost:8080

# Dışarıdan test (Windows PowerShell'den)
curl http://124.243.177.173:8080

# API endpoint'lerini test et
curl http://124.243.177.173:8080/api/health
```

## 🔟 Güvenlik Önerileri

```bash
# SSH şifre girişini devre dışı bırak (SSH key kullan)
nano /etc/ssh/sshd_config
# PasswordAuthentication no
systemctl restart sshd

# Fail2ban kur (brute force koruması)
apt-get install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Otomatik güncellemeleri aktif et
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

## 📊 İzleme ve Bakım

```bash
# Disk kullanımı
df -h

# Bellek kullanımı
free -h

# CPU kullanımı
top
# veya
htop

# Servis yeniden başlatma sayısı
systemctl show posture-detection -p NRestarts

# Son yeniden başlatma zamanı
systemctl show posture-detection -p ActiveEnterTimestamp
```

## 🆘 Acil Durum Komutları

```bash
# Servisi tamamen durdur ve disable et
systemctl stop posture-detection
systemctl disable posture-detection

# Servis dosyasını sil
rm /etc/systemd/system/posture-detection.service
systemctl daemon-reload

# Logları temizle
journalctl --rotate
journalctl --vacuum-time=1s
```

---

## 📝 Notlar

- Servis `root` kullanıcısı ile çalışıyor. Güvenlik için ayrı bir kullanıcı oluşturulabilir.
- `Restart=always` sayesinde servis çökerse otomatik yeniden başlar
- `RestartSec=10` çökme durumunda 10 saniye bekler
- Loglar systemd journal'a yazılır
- Port 8080 varsayılan, `.env` dosyasından değiştirilebilir
