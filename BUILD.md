# Muxy 构建指南

## 环境要求

- macOS 14+
- Swift 6.0+
- `gh` 命令行工具（可选，用于 PR 管理）

## 快速开始

### 1. 初始化项目

```bash
# 下载 GhosttyKit.xcframework
scripts/setup.sh
```

### 2. Debug 构建

```bash
# 清除缓存（如果需要）
rm -rf .build .swiftpm

# 构建
swift build

# 运行
swift run Muxy
```

### 3. Release 构建

```bash
# 清除缓存
rm -rf .build .swiftpm

# 构建 Release 版本
swift build -c release
```

**输出位置：** `.build/release/Muxy`

## 构建 DMG 安装包

### 前置条件

安装 `create-dmg` 工具：

```bash
npm install --global create-dmg
```

### 打包步骤

```bash
# ARM64 架构（Apple Silicon）
scripts/build-release.sh --arch arm64 --version 1.0.0

# x86_64 架构（Intel）
scripts/build-release.sh --arch x86_64 --version 1.0.0
```

**输出位置：** `build/Muxy-1.0.0-arm64.dmg` 或 `build/Muxy-1.0.0-x86_64.dmg`

### 打包脚本参数

| 参数 | 必需 | 说明 | 示例 |
|------|------|------|------|
| `--arch` | ✅ | 架构：`arm64` 或 `x86_64` | `--arch arm64` |
| `--version` | ✅ | 版本号：`X.Y.Z` 或 `X.Y.Z-beta.N` | `--version 1.0.0` |
| `--sign-identity` | ❌ | 代码签名身份 | `--sign-identity "Developer ID Application: Name"` |
| `--sparkle-public-key` | ❌ | 自动更新公钥 | `--sparkle-public-key "key..."` |
| `--sparkle-feed-url` | ❌ | 自动更新 Feed URL | `--sparkle-feed-url "https://..."` |

### 带代码签名的打包

```bash
scripts/build-release.sh \
  --arch arm64 \
  --version 1.0.0 \
  --sign-identity "Developer ID Application: Your Name"
```

### 带自动更新的打包

```bash
scripts/build-release.sh \
  --arch arm64 \
  --version 1.0.0 \
  --sign-identity "Developer ID Application: Your Name" \
  --sparkle-public-key "your-public-key" \
  --sparkle-feed-url "https://your-domain.com/appcast.xml"
```

## 打包脚本工作流程

`scripts/build-release.sh` 执行以下步骤：

1. **编译** - 使用指定架构编译 Release 版本
2. **创建 App Bundle** - 生成 `Muxy.app` 目录结构
3. **嵌入依赖** - 复制 Sparkle.framework 和资源包
4. **生成图标** - 创建 AppIcon.icns
5. **代码签名**（可选）- 签名 Sparkle 组件和主应用
6. **创建 DMG** - 使用 `create-dmg` 生成安装包
7. **签名 DMG**（可选）- 对 DMG 文件进行签名

## 常见问题

### 构建卡住或很慢

**症状：** 编译过程中内存占用过高或进程卡死

**解决方案：**

```bash
# 停止所有编译进程
pkill -9 swift; pkill -9 clang; pkill -9 swiftc

# 完全清除缓存
rm -rf .build .swiftpm build

# 重新运行 setup
scripts/setup.sh

# 用 debug 模式构建（更快）
swift build
```

### UI 修改没有生效

**症状：** 打包后 UI 修改内容没有出现

**解决方案：**

```bash
# 清除所有构建缓存
rm -rf .build .swiftpm build

# 重新运行 setup
scripts/setup.sh

# 重新构建
swift build -c release
```

### create-dmg 未找到

**错误信息：** `Error: create-dmg not found`

**解决方案：**

```bash
npm install --global create-dmg
```

## 版本号格式

- **正式版本：** `1.0.0`, `2.1.3`
- **测试版本：** `1.0.0-beta.1`, `2.0.0-beta.5`

## 相关文件

- `scripts/build-release.sh` - DMG 打包脚本
- `scripts/setup.sh` - 项目初始化脚本
- `Muxy/Info.plist` - 应用信息配置
- `Muxy/Muxy.entitlements` - 代码签名权限配置
- `Package.swift` - Swift Package 配置

## 更多信息

- 官方仓库：https://github.com/muxy-app/muxy
- 发布页面：https://github.com/muxy-app/muxy/releases
