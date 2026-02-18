#!/bin/bash
# Claude No Approve Bash - 一键安装脚本

set -e

echo "🚀 安装 Claude No Approve Bash Skill..."
echo ""

# 检查是否在项目根目录
if [ ! -d ".claude" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    echo "   （应包含 .claude 目录）"
    exit 1
fi

# 复制 skill
echo "📁 复制 Skill 文件..."
cp -r skill/no-approve-bash .claude/skills/

# 创建脚本目录
echo "📁 创建脚本目录..."
mkdir -p ~/.claude-bin

# 检查权限配置
SETTINGS_FILE=".claude/settings.local.json"
if [ -f "$SETTINGS_FILE" ]; then
    echo ""
    echo "🔍 检查权限配置..."

    if grep -q "Bash(~/.claude-bin/\*)" "$SETTINGS_FILE" 2>/dev/null; then
        echo "✅ 已包含 ~/.claude-bin/* 权限"
    else
        echo "⚠️  需要添加权限到 $SETTINGS_FILE："
        echo ""
        echo "请添加以下内容到 permissions.allow 数组："
        echo '  "Bash(bash:*)",'
        echo '  "Bash(~/.claude-bin/*)"'
        echo ""
        echo "配置示例："
        cat << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(bash:*)",
      "Bash(~/.claude-bin/*)",
      ...其他权限
    ]
  }
}
EOF
    fi
else
    echo "ℹ️  未找到 $SETTINGS_FILE"
    echo "   请手动创建并添加权限配置"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📚 使用说明："
echo "   复杂命令会被自动转化为脚本并执行"
echo "   详情: https://github.com/你的用户名/claude-no-approve-bash"
