# Claude No Approve Bash

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

让 Claude Code 无需审批执行复杂 bash 命令的 Skill。

**仓库**：https://github.com/BiuBiuHu/claude-no-approve-bash

[English Version](README.md)

---

## 问题

当使用 Claude Code 执行复杂的 bash 命令时（如 `for` 循环、管道、多命令组合），系统会要求用户反复审批每个操作，影响工作效率。

## 解决方案

将复杂命令转化为脚本，存放到 `~/.claude-bin/` 目录，通过配置权限实现无需审批执行。

## 快速开始

### 方式 1：一键安装

```bash
curl -sSL https://raw.githubusercontent.com/BiuBiuHu/claude-no-approve-bash/main/install.sh | bash
```

### 方式 2：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/BiuBiuHu/claude-no-approve-bash.git
cd claude-no-approve-bash

# 2. 复制 Skill 到项目
cp -r skill/no-approve-bash .claude/skills/

# 3. 配置权限
```

### 配置权限

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

### 验证安装

```bash
# 执行复杂命令测试
for dir in */; do echo "=== $dir ===" && ls "$dir" | head -3; done
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

### 示例 1：遍历目录

**用户输入**：
```
列出每个子目录的前 3 个文件
```

**AI 自动转化**：
```bash
cat > ~/.claude-bin/auto-list-files << 'EOF'
#!/bin/bash
# 列出每个子目录的前 3 个文件

for dir in */; do
    if [ -d "$dir" ]; then
        echo "=== $dir ==="
        ls "$dir" | head -3
    fi
done
EOF
chmod +x ~/.claude-bin/auto-list-files
~/.claude-bin/auto-list-files
```

### 示例 2：多文件搜索

**用户输入**：
```
统计所有 .js 文件中包含 "TODO" 的行数
```

**AI 自动转化**并执行。

### 示例 3：Git 操作

**用户输入**：
```
显示所有 git 仓库子目录的状态
```

**AI 自动转化**：
```bash
cat > ~/.claude-bin/auto-git-status << 'EOF'
#!/bin/bash
# 显示所有 git 仓库的状态

for dir in */; do
    if [ -d "$dir/.git" ]; then
        echo "=== $dir ==="
        cd "$dir" && git status -s && cd ..
    fi
done
EOF
chmod +x ~/.claude-bin/auto-git-status
~/.claude-bin/auto-git-status
```

## 内置工具

| 脚本 | 用途 |
|------|------|
| `make-script-safe` | 安全脚本创建器（内置危险操作检测） |
| `sync-settings` | 检查项目 settings 权限配置 |
| `security-audit` | 审查脚本安全性 |

## 目录结构

```
~/.claude-bin/                    # AI 生成的脚本
.claude/skills/no-approve-bash/   # Skill 定义
├── SKILL.md
└── scripts/                       # 内置工具
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

[MIT](LICENSE)
