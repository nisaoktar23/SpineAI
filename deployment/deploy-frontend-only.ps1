# Deploy only frontend with mock fallback
$SERVER_IP = "124.243.177.173"
$SERVER_USER = "root"
$FRONTEND_DIR = "/var/www/html"
$LOCAL_DIST = "c:\Users\nisa\Desktop\postur_tespit - Kopya - Kopya\frontend\dist"

Write-Host "🚀 Deploying frontend with analysis mock fallback..." -ForegroundColor Cyan

Write-Host "📦 Copying dist folder to server..." -ForegroundColor Yellow
scp -r "$LOCAL_DIST/*" "${SERVER_USER}@${SERVER_IP}:${FRONTEND_DIR}/"

Write-Host "✅ Frontend deployed with 30s timeout + mock fallback!" -ForegroundColor Green
Write-Host "📝 Now 'Start Analysis' button will ALWAYS show results (demo mode if backend fails)" -ForegroundColor Cyan
