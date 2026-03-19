# SpineAI Sunucu Restart Scripti
# Servisler çalışmıyorsa bu scripti çalıştırın

Write-Host "=== SpineAI Servislerini Başlatma ===" -ForegroundColor Cyan
Write-Host ""

$server = "124.243.177.173"

Write-Host "MongoDB başlatılıyor..." -ForegroundColor Yellow
ssh root@$server "systemctl start mongodb"

Write-Host "Posture Detection servisi başlatılıyor..." -ForegroundColor Yellow
ssh root@$server "systemctl start posture-detection"

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Servis durumu:" -ForegroundColor Green
ssh root@$server "systemctl status posture-detection --no-pager | head -15"

Write-Host ""
Write-Host "✅ Servisler başlatıldı!" -ForegroundColor Green
Write-Host "Tarayıcınızda açın: http://124.243.177.173:8080" -ForegroundColor Cyan
