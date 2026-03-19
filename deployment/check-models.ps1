# Backend Model Dosyalarını Kontrol ve Düzeltme Script'i

$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Model Dosyaları Kontrol" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Sunucudaki model dosyaları kontrol ediliyor..." -ForegroundColor Yellow

$checkCommand = "cd /opt/posture-detection/backend && echo '=== Backend dizini ===' && pwd && echo '' && echo '=== ONNX Model dosyaları ===' && ls -lh *.onnx 2>/dev/null || echo 'ONNX dosyaları bulunamadı' && echo '' && echo '=== PyTorch Model dosyaları ===' && ls -lh models/*.pt 2>/dev/null || echo 'PT dosyaları bulunamadı' && echo '' && echo '=== Tüm model dosyaları ===' && find . -maxdepth 2 -name '*.onnx' -o -name '*.pt' | head -20"

ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" $checkCommand

Write-Host ""
Write-Host "[2/2] Servis logları kontrol ediliyor..." -ForegroundColor Yellow

$logCommand = "journalctl -u posture-detection -n 50 --no-pager"

ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" $logCommand

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "✅ Kontrol tamamlandı!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
