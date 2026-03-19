# Posture Detection - Uzak Sunucu Kurulum Script'i
# Bu script Windows'tan Ubuntu sunucusuna deployment yapar

$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"
$SERVER_PASSWORD = "Kenan_avc_4455"
$PROJECT_NAME = "posture-detection"
$REMOTE_DIR = "/opt/$PROJECT_NAME"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Posture Detection Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 1. Proje dosyalarını sıkıştır
Write-Host "[1/6] Proje dosyalari sikistirilıyor..." -ForegroundColor Yellow
$sourceDir = "$PSScriptRoot\.."
$zipFile = "$env:TEMP\posture-detection.zip"

if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# Backend ve deployment klasörlerini sıkıştır
Compress-Archive -Path "$sourceDir\backend", "$sourceDir\deployment", "$sourceDir\frontend" -DestinationPath $zipFile -Force
Write-Host "   Olusturulan ZIP: $zipFile" -ForegroundColor Green

# 2. ZIP dosyasını sunucuya yükle
Write-Host "[2/6] Dosyalar sunucuya yukleniyor..." -ForegroundColor Yellow
Write-Host "   SSH baglantisi kuruluyor: $SERVER_USER@$SERVER_IP" -ForegroundColor Gray

$scpCommand = @"
scp -o StrictHostKeyChecking=no "$zipFile" ${SERVER_USER}@${SERVER_IP}:/tmp/posture-detection.zip
"@

Write-Host "   Komut: $scpCommand" -ForegroundColor Gray
Write-Host "   Sifre girildiginde: $SERVER_PASSWORD" -ForegroundColor Magenta
Write-Host ""

# SCP komutu - kullanıcı şifreyi manuel girecek
& scp -o StrictHostKeyChecking=no "$zipFile" "${SERVER_USER}@${SERVER_IP}:/tmp/posture-detection.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "   HATA: Dosya yukleme basarisiz!" -ForegroundColor Red
    Write-Host "   Manuel yukleme icin:" -ForegroundColor Yellow
    Write-Host "   scp -o StrictHostKeyChecking=no `"$zipFile`" root@124.243.177.173:/tmp/posture-detection.zip" -ForegroundColor White
    exit 1
}

Write-Host "   Yukleme tamamlandi!" -ForegroundColor Green

# 3. Sunucuda kurulum script'ini çalıştır
Write-Host "[3/6] Sunucuda kurulum baslatiliyor..." -ForegroundColor Yellow
Write-Host "   SSH ile baglaniliyor..." -ForegroundColor Gray

# Sunucuda çalıştırılacak komutlar
$remoteCommands = @"
echo '=== 1. Proje dizini hazirlaniyor ==='
apt-get update -qq
apt-get install -y unzip curl

mkdir -p $REMOTE_DIR
cd $REMOTE_DIR
unzip -o /tmp/posture-detection.zip
rm /tmp/posture-detection.zip

echo '=== 2. Node.js kuruluyor ==='
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi
node --version
npm --version

echo '=== 3. Python kuruluyor ==='
if ! command -v python3 &> /dev/null; then
    apt-get install -y python3 python3-pip
fi
python3 --version

echo '=== 4. Backend bagimliliklari yukleniyor ==='
cd $REMOTE_DIR/backend
npm install --production

echo '=== 5. Python bagimliliklari yukleniyor ==='
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
fi

echo '=== 6. Systemd servisi olusturuluyor ==='
cat > /etc/systemd/system/posture-detection.service << 'SERVICEFILE'
[Unit]
Description=Posture Detection Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$REMOTE_DIR/backend
Environment="NODE_ENV=production"
Environment="PORT=8080"
ExecStart=/usr/bin/node $REMOTE_DIR/backend/src/server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=posture-detection

[Install]
WantedBy=multi-user.target
SERVICEFILE

echo '=== 7. Servis aktive ediliyor ==='
systemctl daemon-reload
systemctl enable posture-detection.service
systemctl start posture-detection.service

echo '=== 8. Durum kontrol ediliyor ==='
sleep 3
systemctl status posture-detection.service --no-pager -l

echo '=== 9. Port kontrol ediliyor ==='
netstat -tuln | grep :8080 || echo 'UYARI: Port 8080 henuz dinlenmiyor'

echo ''
echo '==================================='
echo 'KURULUM TAMAMLANDI!'
echo '==================================='
echo ''
echo 'Servis komutlari:'
echo '  systemctl status posture-detection'
echo '  systemctl restart posture-detection'
echo '  journalctl -u posture-detection -f'
echo ''
echo 'Test:'
echo "  curl http://localhost:8080"
echo "  curl http://$SERVER_IP:8080"
"@

# SSH komutu - kullanıcı şifreyi manuel girecek
Write-Host "   Sifre: $SERVER_PASSWORD" -ForegroundColor Magenta
$remoteCommands | ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "bash -s"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "KURULUM BASARILI!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Servisiniz su adreste calisiyor:" -ForegroundColor Yellow
    Write-Host "  http://$SERVER_IP:8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Yonetim komutlari:" -ForegroundColor Yellow
    Write-Host "  ssh root@$SERVER_IP 'systemctl status posture-detection'" -ForegroundColor White
    Write-Host "  ssh root@$SERVER_IP 'systemctl restart posture-detection'" -ForegroundColor White
    Write-Host "  ssh root@$SERVER_IP 'journalctl -u posture-detection -f'" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Red
    Write-Host "KURULUM BASARISIZ!" -ForegroundColor Red
    Write-Host "==================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Loglari kontrol edin:" -ForegroundColor Yellow
    Write-Host "  ssh root@$SERVER_IP 'journalctl -u posture-detection -n 50'" -ForegroundColor White
}

# Geçici ZIP dosyasını temizle
Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
