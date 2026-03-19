# Backend ve Frontend Tam Güncelleme Script'i
# API URL düzeltmeleri ve servis yeniden başlatma

$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"
$PROJECT_NAME = "posture-detection"
$REMOTE_DIR = "/opt/$PROJECT_NAME"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Backend & Frontend Güncelleme" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Frontend ZIP dosyası
$frontendZip = "$PSScriptRoot\..\frontend\frontend-dist-updated.zip"

if (-not (Test-Path $frontendZip)) {
    Write-Host "HATA: Frontend build dosyası bulunamadı!" -ForegroundColor Red
    Write-Host "Önce 'cd frontend && npm run build' komutunu çalıştırın" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/4] Frontend dosyaları sunucuya yükleniyor..." -ForegroundColor Yellow
& scp -o StrictHostKeyChecking=no "$frontendZip" "${SERVER_USER}@${SERVER_IP}:/tmp/frontend-dist.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "HATA: Dosya yükleme başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "[2/4] Sunucuda güncellemeler yapılıyor..." -ForegroundColor Yellow

$sshCommand = "cd /opt/posture-detection/frontend && rm -rf dist/* && unzip -q -o /tmp/frontend-dist.zip -d dist/ && rm /tmp/frontend-dist.zip && cd /opt/posture-detection/backend && ls -la best*.onnx models/best.pt 2>/dev/null || echo 'Model dosyaları kontrol edilmeli' && npm list > /dev/null 2>&1 || npm install && systemctl restart posture-detection && sleep 3 && systemctl status posture-detection --no-pager | head -n 10"

ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" $sshCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "✅ Güncelleme başarıyla tamamlandı!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Site adresi: http://${SERVER_IP}:8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Logları görmek için:" -ForegroundColor Yellow
    Write-Host "ssh ${SERVER_USER}@${SERVER_IP} 'journalctl -u posture-detection -f'" -ForegroundColor White
} else {
    Write-Host "HATA: Güncelleme başarısız!" -ForegroundColor Red
    exit 1
}
