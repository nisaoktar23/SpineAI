$SERVER = "root@124.243.177.173"
$FRONTEND = "/opt/posture-detection/frontend"

Write-Host "Uploading..." -ForegroundColor Cyan
scp -r "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya\frontend\dist" "${SERVER}:${FRONTEND}/"
ssh $SERVER "systemctl restart posture-detection"
Write-Host "Done!" -ForegroundColor Green
