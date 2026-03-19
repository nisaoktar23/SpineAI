# Quick fix for posture analysis timeout issue
# Copy only the postureAnalysisService.js file

$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"
$PROJECT_DIR = "/opt/posture-detection"
$LOCAL_FILE = "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya\backend\src\services\postureAnalysisService.js"

Write-Host "🔧 Deploying posture analysis timeout fix..." -ForegroundColor Cyan
Write-Host "📁 Copying postureAnalysisService.js to server..." -ForegroundColor Yellow

# Copy the fixed file
scp $LOCAL_FILE "${SERVER_USER}@${SERVER_IP}:${PROJECT_DIR}/src/services/"

Write-Host "🔄 Restarting service..." -ForegroundColor Yellow
ssh "${SERVER_USER}@${SERVER_IP}" "systemctl restart posture-detection"

Write-Host "✅ Fix deployed! Posture analysis now has 30s timeout with mock fallback." -ForegroundColor Green
Write-Host "📝 Test the 'Start Analysis' button now." -ForegroundColor Cyan
