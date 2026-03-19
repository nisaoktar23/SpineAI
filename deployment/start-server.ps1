# SpineAI Sunucu Başlatma Scripti
# Kullanım: Bu scripti çalıştırarak sunucunun durumunu kontrol edin

Write-Host "=== SpineAI Sunucu Kontrolü ===" -ForegroundColor Cyan
Write-Host ""

# Sunucu bilgileri
$server = "124.243.177.173"
$url = "http://124.243.177.173:8080"

Write-Host "Sunucu: $server" -ForegroundColor Yellow
Write-Host "URL: $url" -ForegroundColor Yellow
Write-Host ""

# Servislerin durumunu kontrol et
Write-Host "Servis durumu kontrol ediliyor..." -ForegroundColor Green
ssh root@$server "systemctl is-active mongodb posture-detection"

Write-Host ""
Write-Host "Detaylı durum:" -ForegroundColor Green
ssh root@$server "systemctl status posture-detection --no-pager | head -15"

Write-Host ""
Write-Host "=== Giriş Bilgileri ===" -ForegroundColor Cyan
Write-Host "Email: oktarnisa23@gmail.com" -ForegroundColor White
Write-Host "Şifre: 762017Nisa_@" -ForegroundColor White
Write-Host ""
Write-Host "Tarayıcınızda açın: $url" -ForegroundColor Green
