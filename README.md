# Claude No Approve Bash

让 Claude Code 无需审批执行复杂 bash 命令的 Skill。

## 问题

当使用 Claude Code 执行复杂的 bash 命令时（如 `for` 循环、管道、多命令组合），系统会要求用户反复审批每个操作，影响工作效率。

## 解决方案

将复杂命令转化为脚本，存放到 `~/.claude-bin/` 目录，通过配置权限实现无需审批执行。

## 快速开始

### 1. 复制 Skill 到项目

```bash
cp -r skill/no-approve-bash .claude/skills/
```

### 2. 配置权限

在项目的 `.claude/settings.local.json` 中添加：

```json
{
  "permissions": {
    "allow": [
      "Bash(bash:*)",
      "Bash(~/.claude-bin/*)"
    ]
  }
}
```

### 3. 验证安装

```bash
# 执行复杂命令测试
for project in server client; do echo "=== $project ===" && cd "$project" && npm test; done
```

Claude 会自动将其转化为脚本并执行，无需审批。

## 工作原理

```
用户输入复杂命令
       ↓
AI 识别为复杂命令（循环/管道/组合）
       ↓
创建脚本到 ~/.claude-bin/auto-xxx
       ↓
直接执行（已授权，无需审批）
```

## 安全设计

### 白名单机制

只有**已在 settings 中授权**的命令才能组合使用：

| 类别 | 命令 |
|------|------|
| 版本管理 | `git`, `gh` |
| 包管理 | `npm`, `npx`, `yarn`, `pnpm`, `python`, `pip` |
| 文件读取 | `ls`, `cat`, `grep`, `find`, `jq` |
| 网络 | `curl` |
| 部署 | `vercel`, `supabase` |

### 高危操作仍需审批

以下命令**不自动授权**：
- `rm -rf /` / `rm -rf ~/` 系统目录删除
- `dd if=/dev/` 磁盘写入
- `mkfs` 格式化
- fork 炸弹等破坏性操作

## 使用示例

### 示例 1：遍历项目执行命令

**用户输入**：
```
在所有项目中运行 npm test
```

**AI 自动转化**：
```bash
cat > ~/.claude-bin/auto-run-tests << 'EOF'
#!/bin/bash
for project in server ai-service email-service; do
    if [ -d "$project" ]; then
        echo "=== $project ==="
        cd "$project" && npm test
    fi
done
EOF
chmod +x ~/.claude-bin/auto-run-tests
~/.claude-bin/auto-run-tests
```

### 示例 2：查找包含特定内容的文件

**用户输入**：
```
查找所有项目中包含 "react" 的 package.json
```

**AI 自动转化**并执行。

## 内置工具

| 脚本 | 用途 |
|------|------|
| `make-script-safe` | 安全脚本创建器（内置危险操作检测） |
| `sync-settings` | 检查项目 settings 权限配置 |
| `security-audit` | 审查脚本安全性 |

## 目录结构

```
~/.claude-bin/          # AI 生成的脚本
.claude/skills/no-approve-bash/  # Skill 定义
├── SKILL.md
└── scripts/            # 内置工具
```

## License

MIT
