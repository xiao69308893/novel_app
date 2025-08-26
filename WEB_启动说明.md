# Flutter Web 启动指南

## 前提条件
确保您的系统已安装并配置了以下环境：
1. **Flutter SDK** - 版本 3.24.5 或更高
2. **Dart SDK** - 版本 3.0.0 或更高
3. **Chrome浏览器** - 用于Web开发和调试

## 启动方法

### 方法一：使用提供的脚本
1. **Windows批处理脚本**：
   ```
   双击运行 start_web.bat
   ```

2. **PowerShell脚本**：
   ```
   右键 start_web.ps1 -> 使用PowerShell运行
   ```

### 方法二：手动命令行启动
1. 打开终端/命令提示符
2. 切换到项目目录：
   ```bash
   cd e:\workspace\python\2025\novel\novel_app
   ```
3. 启动Web服务器：
   ```bash
   flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
   ```

### 方法三：使用VSCode
1. 打开VSCode并加载项目
2. 按 `Ctrl+Shift+P` 打开命令面板
3. 输入 "Flutter: Launch Emulator"
4. 选择 "Web (Chrome)" 或 "Web Server"

## 访问应用
启动成功后，在浏览器中访问：
- **本地访问**：http://localhost:8080
- **网络访问**：http://[您的IP地址]:8080

## 常见问题

### 1. Flutter命令未找到
- 确保Flutter SDK已正确安装
- 检查PATH环境变量是否包含Flutter路径
- 运行 `flutter doctor` 检查环境配置

### 2. Web支持未启用
```bash
flutter config --enable-web
```

### 3. 依赖问题
```bash
flutter pub get
flutter pub upgrade
```

### 4. 构建错误
```bash
flutter clean
flutter pub get
flutter run -d web-server
```

## 开发模式功能
- **热重载**：修改代码后自动刷新
- **调试工具**：按F12打开浏览器开发者工具
- **性能分析**：使用Flutter Inspector

## 生产构建
如需构建生产版本：
```bash
flutter build web
```
构建结果位于 `build/web/` 目录中。

## 项目结构
```
web/
├── index.html          # 主HTML文件
├── manifest.json       # PWA清单文件
├── favicon.png         # 网站图标
└── icons/             # 应用图标集合
```

## 技术栈
- **前端框架**：Flutter Web
- **状态管理**：flutter_bloc + provider
- **网络请求**：dio
- **本地存储**：shared_preferences + sqflite
- **UI组件**：Material Design + Cupertino

## 支持的浏览器
- Chrome 84+
- Firefox 72+
- Safari 14+
- Edge 84+