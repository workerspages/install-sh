#!/bin/bash

# =======================================================
# v2rayN for Ubuntu Desktop 一键安装/更新脚本
# 项目地址: https://github.com/2dust/v2rayN
# =======================================================

set -e

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置项
GITHUB_REPO="2dust/v2rayN"
INSTALL_DIR="/opt/v2rayN"
DESKTOP_FILE="/usr/share/applications/v2rayN.desktop"
# 假设官方的 Linux 发行版包含 "linux-64" 或类似关键字
# 如果官方命名不同，请修改此处的关键字，例如 "linux-x64"
ASSET_KEYWORD="linux" 

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  开始安装/更新 v2rayN (Ubuntu Desktop) ${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. 检查并安装必要依赖
echo -e "${YELLOW}>> 检查并安装依赖 (curl, jq, unzip, wget)...${NC}"
sudo apt-get update -yqq
sudo apt-get install -yqq curl jq unzip wget desktop-file-utils

# 2. 获取最新版本信息
echo -e "${YELLOW}>> 正在从 GitHub API 获取最新版本信息...${NC}"
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")
VERSION=$(echo "$LATEST_RELEASE" | jq -r .tag_name)

if [ "$VERSION" == "null" ] || [ -z "$VERSION" ]; then
    echo -e "${RED}错误: 无法获取最新版本号，请检查网络或 GitHub API 限制。${NC}"
    exit 1
fi

echo -e "${GREEN}>> 发现最新版本: ${VERSION}${NC}"

# 3. 筛选 Linux 版本的下载链接
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | ascii_downcase | contains(\"${ASSET_KEYWORD}\")) | .browser_download_url" | head -n 1)
ASSET_NAME=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | ascii_downcase | contains(\"${ASSET_KEYWORD}\")) | .name" | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}错误: 在 ${VERSION} 版本中未找到包含 '${ASSET_KEYWORD}' 的发布文件。${NC}"
    echo -e "${YELLOW}注: v2rayN 官方目前可能未提供原生的 Linux 预编译包。推荐在 Ubuntu 上使用 v2rayA 或 nekoray。${NC}"
    exit 1
fi

echo -e "${GREEN}>> 找到下载链接: ${DOWNLOAD_URL}${NC}"

# 4. 下载并解压
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo -e "${YELLOW}>> 正在下载 ${ASSET_NAME} ...${NC}"
wget -q --show-progress "$DOWNLOAD_URL" -O "$ASSET_NAME"

echo -e "${YELLOW}>> 正在清理旧版本并安装到 ${INSTALL_DIR} ...${NC}"
# 如果 v2rayN 正在运行，先终止进程
pkill -f "v2rayN" || true

sudo rm -rf "${INSTALL_DIR}"
sudo mkdir -p "${INSTALL_DIR}"
sudo unzip -q "$ASSET_NAME" -d "${INSTALL_DIR}"

# 赋予执行权限 (假设主程序名为 v2rayN)
if [ -f "${INSTALL_DIR}/v2rayN" ]; then
    sudo chmod +x "${INSTALL_DIR}/v2rayN"
    EXEC_PATH="${INSTALL_DIR}/v2rayN"
else
    # 尝试寻找目录下的可执行文件
    EXEC_PATH=$(find "${INSTALL_DIR}" -maxdepth 2 -type f -executable | head -n 1)
    if [ -n "$EXEC_PATH" ]; then
        sudo chmod +x "$EXEC_PATH"
    fi
fi

# 下载官方图标 (如果压缩包内没有，可以提供一个备用图标)
ICON_PATH="${INSTALL_DIR}/v2rayN.png"
if [ ! -f "$ICON_PATH" ]; then
    sudo wget -q "https://raw.githubusercontent.com/${GITHUB_REPO}/master/v2rayN/v2rayN/v2rayN.ico" -O "${INSTALL_DIR}/v2rayN.ico" || true
    # Ubuntu 桌面图标最好是 png/svg
    ICON_PATH="${INSTALL_DIR}/v2rayN.ico"
fi

# 5. 创建桌面快捷方式
echo -e "${YELLOW}>> 正在创建桌面快捷方式...${NC}"
sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Name=v2rayN
Comment=A GUI client for v2ray
Exec=${EXEC_PATH}
Icon=${ICON_PATH}
Terminal=false
Type=Application
Categories=Network;
EOF

sudo update-desktop-database /usr/share/applications

# 6. 清理临时文件
cd ~
rm -rf "$TMP_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  v2rayN ${VERSION} 安装/更新成功！${NC}"
echo -e "${GREEN}  您可以在应用程序菜单中搜索 'v2rayN' 启动。${NC}"
echo -e "${GREEN}========================================${NC}"
