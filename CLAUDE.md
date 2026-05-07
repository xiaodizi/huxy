# Muxy 开发指南

## 环境要求

- macOS 14+ / Swift 6.0+
- 工具版本（见 `.tool-versions`）：swiftformat 0.60.1, swiftlint 0.57.1
- `gh` CLI（用于下载 GhosttyKit）

## 开发命令

```bash
scripts/setup.sh          # 首次下载 GhosttyKit.xcframework 和资源
swift build               # 调试构建
swift run Muxy            # 运行应用
scripts/checks.sh         # 运行所有检查（format → lint → build → test）
scripts/checks.sh --fix   # 自动修复格式化和 lint 问题
```

## 项目结构

| 目录 | 用途 |
|------|------|
| `Muxy/` | 主应用（SwiftUI + AppKit） |
| `MuxyShared/` | 共享代码（状态、工具类） |
| `MuxyServer/` | 本地网络 WebSocket API（iOS/Android 客户端） |
| `GhosttyKit/` | C 模块包装 libghostty API |
| `GhosttyKit.xcframework/` | 预编译静态库（gitignored，通过 setup.sh 下载） |

## 数据持久化

- 项目：`~/Library/Application Support/Muxy/projects.json`
- Ghostty 配置：`~/.config/ghostty/config`
- 终端状态（tabs、splits）：仅内存，关闭后丢失

## NSViewRepresentable 陷阱

- 禁止在 `makeNSView` 中返回缓存/复用的 NSView（会导致空白视图）
- 跨 tab 保持 NSView 存活：使用 ZStack + `opacity(0)` + `allowsHitTesting(false)` 而非条件移除

## 代码规范

- 禁止注释，代码必须自解释
- 使用 early returns，避免嵌套条件
- 修复根因，不修补症状
- 可测试的功能必须写测试
- PR 描述不超过 3 行，需包含截图或录屏

## 架构文档

详细架构说明见 `./docs/developer/architecture/README.md`
