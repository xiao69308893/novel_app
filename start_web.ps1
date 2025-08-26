# Flutter Web启动脚本
Write-Host "正在启动Flutter Web服务器..." -ForegroundColor Green
Write-Host "项目目录: $(Get-Location)" -ForegroundColor Yellow

# 检查Flutter是否可用
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter版本信息:" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor White
} catch {
    Write-Host "错误: Flutter命令未找到，请确保Flutter已正确安装并添加到PATH环境变量中" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 启动Web服务器
Write-Host "正在启动Web服务器，端口: 8080" -ForegroundColor Green
Write-Host "启动后请在浏览器中访问: http://localhost:8080" -ForegroundColor Yellow

try {
    flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
} catch {
    Write-Host "启动失败: $_" -ForegroundColor Red
    Read-Host "按任意键退出"
}