---
name: no-approve-bash
description: 无需审批的、已在 settings allow 中的 bash 命令组合能力。高危操作（rm -rf 系统、mv 系统文件等）仍需审批。
---

# No Approve Bash Skill

将**已授权的** bash 命令组合成复杂脚本（循环、管道、多命令组合），实现无需审批执行。

## 问题

当用户需要执行复杂的 bash 命令时，如：
- `for` 循环遍历项目
- 管道 `|` 连接多个命令
- `&&` / `||` 组合操作

Claude Code 会要求用户审批每个操作，影响效率。

## 解决方案

将复杂命令转化为脚本，存放到 `~/.claude-bin/` 目录，通过配置权限实现无需审批执行。

## 前置要求

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

## 使用方式

### 示例 1：遍历项目执行命令

**用户输入**：
```
在所有项目中运行 npm test
```

**AI 自动转化**：
```bash
cat > ~/.claude-bin/auto-run-tests << 'EOF'
#!/bin/bash
# 在所有项目中运行测试

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
在所有项目的 package.json 中查找包含 "react" 的行
```

**AI 自动转化**：
```bash
cat > ~/.claude-bin/auto-find-react << 'EOF'
#!/bin/bash
# 查找包含 react 的 package.json

for dir in */; do
    if [ -f "$dir/package.json" ]; then
        result=$(grep "react" "$dir/package.json")
        if [ -n "$result" ]; then
            echo "$dir: $result"
        fi
    fi
done
EOF
chmod +x ~/.claude-bin/auto-find-react
~/.claude-bin/auto-find-react
```

## 白名单命令（已授权的命令）

只有**已在 settings 中授权**的命令才能组合使用：

| 类别 | 命令 | 需要权限 |
|------|------|----------|
| 版本管理 | `git`, `gh` | `Bash(git:*)` |
| 包管理 | `npm`, `npx`, `yarn`, `pnpm`, `python`, `pip`, `brew` | `Bash(npm:*)` 等 |
| 文件读取 | `ls`, `cat`, `head`, `tail`, `find`, `grep`, `sed`, `awk`, `xargs`, `jq` | `Bash(grep:*)` 等 |
| 目录操作 | `cd`, `mkdir`, `pwd` | `Bash(cd:*)`, `Bash(mkdir:*)` |
| 网络 | `curl` | `Bash(curl:*)` |
| 部署 | `vercel`, `supabase` | `Bash(vercel:*)` |
| 数据库 | `psql`, `redis-cli`, `sqlite3` | `Bash(psql:*)` 等 |
| 系统 | `lsof`, `tee`, `echo`, `ps` | `Bash(lsof:*)` 等 |
| Shell | `bash`, `sh`, `node` | `Bash(bash:*)` |

## 高危操作（仍需审批）

以下命令**不在白名单中**，即使组合到脚本中也仍需用户审批：

| 命令 | 风险 | 示例 |
|------|------|------|
| `rm` | 数据删除 | `rm -rf node_modules` 可用，`rm -rf /` 需审批 |
| `mv` | 文件移动 | 移动系统文件需审批 |
| `dd` | 磁盘写入 | `dd if=/dev/zero` 破坏性强 |
| `mkfs` | 格式化 | 会删除所有数据 |
| `kill -9` | 强制杀进程 | 可能影响系统稳定性 |
| `:(){ :|:& };:` | fork 炸弹 | 系统崩溃 |

**安全原则**：
- 删除项目内文件（如 `rm -rf node_modules`）允许
- 删除系统目录（如 `rm -rf /usr`）禁止
- AI 遇到高危操作必须先询问用户

## 脚本命名规范

- 自动生成的脚本前缀：`auto-`
- 手动创建的脚本：描述性名称，如 `check-ports`, `list-deps`

## 相关文件

- 脚本目录：`~/.claude-bin/`
- 权限配置：`.claude/settings.local.json`
