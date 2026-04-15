# MobileFFmpeg 快速开始指南

本文档提供 MobileFFmpeg 自定义构建的快速入门指南。

## 前置条件

1. **安装基础工具**：
   ```bash
   brew install autoconf automake libtool pkg-config curl cmake gcc gperf texinfo yasm nasm bison autogen patch git
   ```

2. **设置环境变量**：
   ```bash
   export ANDROID_NDK_ROOT=/path/to/your/android-ndk
   export PATH=$ANDROID_NDK_ROOT/prebuilt/darwin-x86_64/bin:$PATH
   ```

## 快速构建

### 方法一：使用构建脚本（推荐）

1. **标准构建**（包含常用库）：
   ```bash
   ./build_custom.sh --standard
   ```

2. **完整构建**（所有架构）：
   ```bash
   ./build_custom.sh --full
   ```

3. **最小构建**（仅 arm64-v8a）：
   ```bash
   ./build_custom.sh --minimal
   ```

### 方法二：直接使用官方脚本

```bash
./android.sh --disable-arm-v7a-neon \
  --enable-libpng \
  --enable-openh264
```

## 构建输出

构建完成后，输出文件位于：

- **AAR 文件**：`prebuilt/android-aar/`
- **预编译库**：`prebuilt/android-arm/`, `prebuilt/android-arm64/`, 等

## 在 Android 项目中使用

1. **添加依赖**（在 `build.gradle` 中）：
   ```gradle
   implementation files('path/to/your/mobile-ffmpeg.aar')
   ```

2. **基本使用**：
   ```java
   import com.arthenica.mobileffmpeg.FFmpeg;
   
   int rc = FFmpeg.execute("-i input.mp4 -c:v libx264 output.mp4");
   if (rc == 0) {
       // 执行成功
   }
   ```

## 常见问题

### 构建失败
- 检查 `build.log` 文件获取详细错误信息
- 确保所有依赖工具已正确安装
- 验证环境变量设置正确

### 许可证问题
- 当前配置未启用任何 GPL 库，构建产物为 LGPL 许可
- openh264 需要 MPEG LA 许可费用

## 更多信息

- 详细构建流程：查看 [BUILD_GUIDE.md](BUILD_GUIDE.md)
- 完整文档：查看 [README.md](README.md)
- 官方 Wiki：https://github.com/tanersener/mobile-ffmpeg/wiki

## 示例配置

### 标准构建（推荐）
```bash
./build_custom.sh --standard
```

### 最小构建（仅 arm64-v8a）
```bash
./build_custom.sh --minimal
```

### 完整构建
```bash
./build_custom.sh --full
```

## 帮助信息

查看构建脚本的帮助信息：
```bash
./build_custom.sh --help
```

## 注意事项

1. 首次构建可能需要较长时间（30分钟以上）
2. 确保有足够的磁盘空间（至少 5GB）
3. 构建过程中不要中断，否则需要重新开始