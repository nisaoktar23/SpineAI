# Canlı Log İzleme Script'i

$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Canlı Log İzleme Başlatılıyor" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 SpineAI backend logları canlı olarak izlenecek" -ForegroundColor Yellow
Write-Host "🔍 Şimdi sitede analiz yapmayı deneyin..." -ForegroundColor Yellow
Write-Host "⏹️  Durdurmak için Ctrl+C basın" -ForegroundColor Yellow
Write-Host ""

ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "journalctl -u posture-detection -f"
