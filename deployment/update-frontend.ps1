# Frontend Güncelleme Script'i
# Sadece frontend dosyalarını sunucuya yükler

$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"
$PROJECT_NAME = "posture-detection"
$REMOTE_DIR = "/opt/$PROJECT_NAME"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Frontend Güncelleme" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Frontend ZIP dosyası
$zipFile = "$PSScriptRoot\..\frontend\frontend-dist-updated.zip"

if (-not (Test-Path $zipFile)) {
    Write-Host "HATA: Frontend build dosyası bulunamadı!" -ForegroundColor Red
    Write-Host "Önce 'cd frontend && npm run build' komutunu çalıştırın" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/3] Frontend dosyaları sunucuya yükleniyor..." -ForegroundColor Yellow
& scp -o StrictHostKeyChecking=no "$zipFile" "${SERVER_USER}@${SERVER_IP}:/tmp/frontend-dist.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Dosya yükleme başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "[2/3] Sunucuda frontend güncelleniyor..." -ForegroundColor Yellow

$sshCommands = @"
cd $REMOTE_DIR/frontend || exit 1
echo '🗑️  Eski dist klasörü temizleniyor...'
rm -rf dist/*
echo '📦 Yeni dosyalar açılıyor...'
unzip -q -o /tmp/frontend-dist.zip -d dist/
echo '🧹 Geçici dosyalar temizleniyor...'
rm /tmp/frontend-dist.zip
echo '✅ Frontend güncelleme tamamlandı!'
ls -lh dist/
"@

$sshCommands | ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "bash -s"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "✅ Frontend başarıyla güncellendi!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Site adresi: http://${SERVER_IP}:8080" -ForegroundColor Cyan
} else {
    Write-Host "HATA: Sunucuda güncelleme başarısız!" -ForegroundColor Red
    exit 1
}
