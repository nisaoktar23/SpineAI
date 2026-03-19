#!/bin/bash

# Posture Detection Service Kurulum Script'i
# Bu script'i sunucuda root olarak çalıştırın

set -e

echo "🚀 Posture Detection Service kurulumu başlıyor..."

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Proje dizini
PROJECT_DIR="/opt/posture-detection"

# 1. Gerekli paketleri kontrol et
echo -e "${YELLOW}📦 Gerekli paketler kontrol ediliyor...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js bulunamadı. Kuruluyor...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 bulunamadı. Kuruluyor...${NC}"
    apt-get update
    apt-get install -y python3 python3-pip
fi

echo -e "${GREEN}✓ Tüm gerekli paketler mevcut${NC}"

# 2. Proje dizinini oluştur
echo -e "${YELLOW}📁 Proje dizini hazırlanıyor...${NC}"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# 3. Backend bağımlılıklarını yükle
if [ -d "$PROJECT_DIR/backend" ]; then
    echo -e "${YELLOW}📦 Backend bağımlılıkları yükleniyor...${NC}"
    cd $PROJECT_DIR/backend
    npm install --production
    
    # Python bağımlılıkları
    if [ -f "requirements.txt" ]; then
        echo -e "${YELLOW}🐍 Python bağımlılıkları yükleniyor...${NC}"
        pip3 install -r requirements.txt
    fi
fi

# 4. Systemd servis dosyasını kopyala
echo -e "${YELLOW}⚙️  Systemd servisi kuruluyor...${NC}"
cat > /etc/systemd/system/posture-detection.service << 'EOF'
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
EOF

# 5. Servisi aktif et
echo -e "${YELLOW}🔄 Servis aktive ediliyor...${NC}"
systemctl daemon-reload
systemctl enable posture-detection.service
systemctl start posture-detection.service

# 6. Durum kontrolü
sleep 2
if systemctl is-active --quiet posture-detection.service; then
    echo -e "${GREEN}✓ Servis başarıyla başlatıldı!${NC}"
    systemctl status posture-detection.service --no-pager
else
    echo -e "${RED}✗ Servis başlatılamadı. Loglara bakın:${NC}"
    journalctl -u posture-detection.service -n 50 --no-pager
    exit 1
fi

# 7. Port kontrolü
echo -e "\n${YELLOW}🔍 Port kontrolü...${NC}"
if netstat -tuln | grep -q ":8080 "; then
    echo -e "${GREEN}✓ Port 8080 dinleniyor${NC}"
else
    echo -e "${YELLOW}⚠ Port 8080 henüz dinlenmiyor, birkaç saniye bekleyin...${NC}"
fi

echo -e "\n${GREEN}🎉 Kurulum tamamlandı!${NC}"
echo -e "\n${YELLOW}Kullanışlı komutlar:${NC}"
echo -e "  - Servis durumu: ${GREEN}systemctl status posture-detection${NC}"
echo -e "  - Servisi başlat: ${GREEN}systemctl start posture-detection${NC}"
echo -e "  - Servisi durdur: ${GREEN}systemctl stop posture-detection${NC}"
echo -e "  - Servisi yeniden başlat: ${GREEN}systemctl restart posture-detection${NC}"
echo -e "  - Logları görüntüle: ${GREEN}journalctl -u posture-detection -f${NC}"
