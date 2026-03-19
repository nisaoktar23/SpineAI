#!/bin/bash

# Posture Detection - Sunucu Kurulum Script'i
# Bu script'i dogrudan Ubuntu sunucusunda root olarak calistirin

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Degiskenler
PROJECT_DIR="/opt/posture-detection"
SERVICE_NAME="posture-detection"
PORT=8080

echo -e "${BLUE}=================================="
echo -e "Posture Detection Kurulum"
echo -e "==================================${NC}"
echo ""

# 1. Node.js Kurulumu
echo -e "${YELLOW}[1/9] Node.js kuruluyor...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js bulunamadi, kuruluyor...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    echo -e "${GREEN}✓ Node.js kuruldu: $(node --version)${NC}"
else
    echo -e "${GREEN}✓ Node.js zaten kurulu: $(node --version)${NC}"
fi

# 2. Python Kurulumu
echo -e "${YELLOW}[2/9] Python kuruluyor...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Python3 bulunamadi, kuruluyor...${NC}"
    apt-get update
    apt-get install -y python3 python3-pip
    echo -e "${GREEN}✓ Python kuruldu: $(python3 --version)${NC}"
else
    echo -e "${GREEN}✓ Python zaten kurulu: $(python3 --version)${NC}"
fi

# 3. Gerekli araçları kur
echo -e "${YELLOW}[3/9] Gerekli araclar kuruluyor...${NC}"
apt-get install -y unzip curl net-tools
echo -e "${GREEN}✓ Araclar kuruldu${NC}"

# 4. Proje dizinini oluştur
echo -e "${YELLOW}[4/9] Proje dizini hazirlaniyor...${NC}"
mkdir -p $PROJECT_DIR
echo -e "${GREEN}✓ Dizin olusturuldu: $PROJECT_DIR${NC}"

# 5. Backend bağımlılıklarını kontrol et
echo -e "${YELLOW}[5/9] Proje dosyalari kontrol ediliyor...${NC}"
if [ -d "$PROJECT_DIR/backend" ]; then
    echo -e "${GREEN}✓ Backend klasoru mevcut${NC}"
    
    # Node.js bağımlılıkları
    echo -e "${YELLOW}   Node.js bagimliliklari yukleniyor...${NC}"
    cd $PROJECT_DIR/backend
    npm install --production
    echo -e "${GREEN}✓ Node.js bagimliliklari yuklendi${NC}"
    
    # Python bağımlılıkları
    if [ -f "requirements.txt" ]; then
        echo -e "${YELLOW}   Python bagimliliklari yukleniyor...${NC}"
        pip3 install -r requirements.txt
        echo -e "${GREEN}✓ Python bagimliliklari yuklendi${NC}"
    fi
else
    echo -e "${RED}✗ HATA: Backend klasoru bulunamadi!${NC}"
    echo -e "${YELLOW}Lutfen once projenizi $PROJECT_DIR dizinine yukleyin:${NC}"
    echo -e "  Windows'tan: scp -r backend root@124.243.177.173:$PROJECT_DIR/"
    echo -e "  veya WinSCP/FileZilla kullanin"
    exit 1
fi

# 6. .env dosyası oluştur (yoksa)
echo -e "${YELLOW}[6/9] Environment dosyasi hazirlaniyor...${NC}"
if [ ! -f "$PROJECT_DIR/backend/.env" ]; then
    cat > $PROJECT_DIR/backend/.env << 'ENVFILE'
NODE_ENV=production
PORT=8080
JWT_SECRET=super-secret-key-change-this-in-production-2026
MONGODB_URI=mongodb://localhost:27017/posture_detection
ENVFILE
    echo -e "${GREEN}✓ .env dosyasi olusturuldu${NC}"
else
    echo -e "${GREEN}✓ .env dosyasi zaten mevcut${NC}"
fi

# 7. Systemd servis dosyası oluştur
echo -e "${YELLOW}[7/9] Systemd servisi olusturuluyor...${NC}"
cat > /etc/systemd/system/${SERVICE_NAME}.service << SERVICEFILE
[Unit]
Description=Posture Detection Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$PROJECT_DIR/backend
Environment="NODE_ENV=production"
Environment="PORT=$PORT"
ExecStart=/usr/bin/node $PROJECT_DIR/backend/src/server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$SERVICE_NAME

[Install]
WantedBy=multi-user.target
SERVICEFILE
echo -e "${GREEN}✓ Servis dosyasi olusturuldu: /etc/systemd/system/${SERVICE_NAME}.service${NC}"

# 8. Servisi aktif et
echo -e "${YELLOW}[8/9] Servis aktive ediliyor...${NC}"
systemctl daemon-reload
systemctl enable ${SERVICE_NAME}.service
systemctl restart ${SERVICE_NAME}.service
echo -e "${GREEN}✓ Servis aktif edildi${NC}"

# 9. Durum kontrolü
echo -e "${YELLOW}[9/9] Durum kontrol ediliyor...${NC}"
sleep 3

if systemctl is-active --quiet ${SERVICE_NAME}.service; then
    echo -e "${GREEN}✓ Servis basariyla baslatildi!${NC}"
    echo ""
    systemctl status ${SERVICE_NAME}.service --no-pager -l
    echo ""
    
    # Port kontrolü
    if netstat -tuln | grep -q ":$PORT "; then
        echo -e "${GREEN}✓ Port $PORT dinleniyor${NC}"
    else
        echo -e "${YELLOW}⚠ Port $PORT henuz dinlenmiyor, birkac saniye bekleyin...${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}=================================="
    echo -e "KURULUM TAMAMLANDI! ✓"
    echo -e "==================================${NC}"
    echo ""
    echo -e "${BLUE}Servis Adresi:${NC}"
    echo -e "  http://$(hostname -I | awk '{print $1}'):$PORT"
    echo -e "  http://124.243.177.173:$PORT"
    echo ""
    echo -e "${BLUE}Yonetim Komutlari:${NC}"
    echo -e "  ${GREEN}systemctl status $SERVICE_NAME${NC}     # Durum"
    echo -e "  ${GREEN}systemctl restart $SERVICE_NAME${NC}    # Yeniden baslat"
    echo -e "  ${GREEN}systemctl stop $SERVICE_NAME${NC}       # Durdur"
    echo -e "  ${GREEN}journalctl -u $SERVICE_NAME -f${NC}     # Canli loglar"
    echo ""
    echo -e "${BLUE}Test:${NC}"
    echo -e "  ${GREEN}curl http://localhost:$PORT${NC}"
    echo ""
else
    echo -e "${RED}✗ Servis baslatılamadı!${NC}"
    echo ""
    echo -e "${YELLOW}Loglari kontrol edin:${NC}"
    journalctl -u ${SERVICE_NAME}.service -n 50 --no-pager
    exit 1
fi
