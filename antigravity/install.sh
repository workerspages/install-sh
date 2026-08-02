#!/bin/bash
set -e

echo "================================================="
echo "   正在为你安装 Antigravity IDE...             "
echo "================================================="

URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.1.1-6123990880747520/linux-x64/Antigravity%20IDE.tar.gz"
TMP_DIR=$(mktemp -d)

echo "==> 1/4 开始下载压缩包 (这可能需要几分钟)..."
wget -q --show-progress -O "$TMP_DIR/ide.tar.gz" "$URL"

echo "==> 2/4 正在解压到 /opt 目录 (需要 sudo 权限，请根据提示输入密码)..."
sudo mkdir -p /opt/antigravity-temp
sudo tar -xzf "$TMP_DIR/ide.tar.gz" -C /opt/antigravity-temp

# 动态获取解压出的文件夹名，并移动到最终的 /opt/antigravity 目录
EXTRACTED_DIR=$(ls -1 /opt/antigravity-temp | head -n 1)
sudo rm -rf /opt/antigravity
sudo mv "/opt/antigravity-temp/$EXTRACTED_DIR" /opt/antigravity
sudo rm -rf /opt/antigravity-temp

echo "==> 3/4 寻找启动程序和图标..."
# 找出根目录下体积最大的可执行文件作为主程序 (完美避开干扰文件)
EXEC_SCRIPT=$(find /opt/antigravity -maxdepth 1 -type f -executable ! -name "*.so*" -exec ls -s {} + | sort -n -r | head -n 1 | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//')
ICON_PATH="/opt/antigravity/resources/app/resources/linux/code.png"

if [ -z "$EXEC_SCRIPT" ]; then
    echo "❌ 未找到可执行文件，请检查下载的文件是否完整。"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "==> 4/4 创建桌面快捷方式并配置权限..."
# 写入桌面配置，强制加上刚才验证成功的 --no-sandbox 参数
cat <<DESKTOP | sudo tee /usr/share/applications/antigravity.desktop > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE
Icon=${ICON_PATH}
Exec="${EXEC_SCRIPT}" --no-sandbox %F
Comment=Antigravity Development Environment
Categories=Development;IDE;
Terminal=false
DESKTOP

# 确保所有用户都有权限读取和执行
sudo chmod -R 755 /opt/antigravity
# 修复 Electron 沙盒权限 (防患于未然)
sudo chown root:root /opt/antigravity/chrome-sandbox || true
sudo chmod 4755 /opt/antigravity/chrome-sandbox || true

# 清理临时文件
rm -rf "$TMP_DIR"

echo "================================================="
echo "✅ 安装成功！"
echo "👉 现在你可以按 Super(Win) 键打开应用列表，搜索 'Antigravity' 直接启动。"
echo "================================================="
