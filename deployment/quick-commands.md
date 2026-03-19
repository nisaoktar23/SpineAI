# ⚡ Hızlı Komut Referansı

## 🔌 Bağlantı
```bash
ssh root@124.243.177.173
```

## 🚀 Tek Komutla Kurulum
```bash
cd /opt/posture-detection/deployment && chmod +x setup-service.sh && ./setup-service.sh
```

## 📦 Servis Yönetimi
```bash
# Başlat
systemctl start posture-detection

# Durdur
systemctl stop posture-detection

# Yeniden Başlat
systemctl restart posture-detection

# Durum
systemctl status posture-detection

# Aktif et (otomatik başlatma)
systemctl enable posture-detection

# Devre dışı bırak
systemctl disable posture-detection
```

## 📋 Log Kontrolü
```bash
# Canlı loglar
journalctl -u posture-detection -f

# Son 50 satır
journalctl -u posture-detection -n 50

# Bugünkü loglar
journalctl -u posture-detection --since today

# Hata logları
journalctl -u posture-detection -p err
```

## 🔍 Port Kontrolü
```bash
# Tüm dinlenen portlar
netstat -tuln | grep LISTEN

# 8080 portu
netstat -tuln | grep :8080

# Process'e göre port
lsof -i :8080
```

## 🔄 Güncelleme
```bash
# Kod güncelleme
cd /opt/posture-detection
git pull

# Bağımlılıkları güncelle
cd backend && npm install

# Servisi yeniden başlat
systemctl restart posture-detection
```

## 🧪 Test
```bash
# Lokal test
curl http://localhost:8080

# Dış test
curl http://124.243.177.173:8080

# Health check
curl http://localhost:8080/api/health
```

## 🛠️ Sorun Giderme
```bash
# Manuel çalıştır (debug)
cd /opt/posture-detection/backend
node src/server.js

# Node.js versiyonu
node --version

# Çalışan process'ler
ps aux | grep node

# 8080 portunu kullanan process'i öldür
lsof -ti:8080 | xargs kill -9
```

## 📊 Sistem İzleme
```bash
# Disk
df -h

# RAM
free -h

# CPU
top

# Servis yeniden başlatma sayısı
systemctl show posture-detection -p NRestarts
```

## 🔥 Acil Durum
```bash
# Servisi durdur ve sil
systemctl stop posture-detection
systemctl disable posture-detection
rm /etc/systemd/system/posture-detection.service
systemctl daemon-reload
```
