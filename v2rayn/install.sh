#!/bin/bash

# =======================================================
# v2rayN for Ubuntu Desktop 一键安装/更新脚本
# 项目地址: https://github.com/2dust/v2rayN
# =======================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GITHUB_REPO="2dust/v2rayN"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  开始安装/更新 v2rayN (Ubuntu Desktop) ${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. 自动识别系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        DEB_KEYWORD="linux-64.deb"
        ;;
    aarch64|arm64)
        DEB_KEYWORD="linux-arm64.deb"
        ;;
    loongarch64)
        DEB_KEYWORD="linux-loong64.deb"
        ;;
    riscv64)
        DEB_KEYWORD="linux-riscv64.deb"
        ;;
    *)
        echo -e "${RED}错误: 暂不支持当前系统架构 ($ARCH)${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}>> 检测到系统架构: ${ARCH}${NC}"

# 2. 检查基础工具依赖
echo -e "${YELLOW}>> 检查必要工具 (curl, jq, wget)...${NC}"
sudo apt-get update -yqq
sudo apt-get install -yqq curl jq wget

# 3. 获取 GitHub 最新 Release 信息
echo -e "${YELLOW}>> 正在获取 GitHub 最新版本信息...${NC}"
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")
VERSION=$(echo "$LATEST_RELEASE" | jq -r .tag_name)

if [ "$VERSION" == "null" ] || [ -z "$VERSION" ]; then
    echo -e "${RED}错误: 无法获取最新版本号，请检查网络连接或 GitHub API 限制。${NC}"
    exit 1
fi

echo -e "${GREEN}>> 发现最新版本: ${VERSION}${NC}"

# 4. 筛选对应架构的 .deb 安装包 (过滤掉 .sig 签名文件)
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | endswith(\"${DEB_KEYWORD}\")) | .browser_download_url")

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}错误: 未能在最新发布页中找到对应的 ${DEB_KEYWORD} 安装包。${NC}"
    exit 1
fi

FILE_NAME=$(basename "$DOWNLOAD_URL")
TMP_DIR=$(mktemp -d)
TMP_FILE="${TMP_DIR}/${FILE_NAME}"

# 5. 下载并调用 apt 安装
echo -e "${YELLOW}>> 正在下载 ${FILE_NAME} ...${NC}"
wget -q --show-progress "$DOWNLOAD_URL" -O "$TMP_FILE"

echo -e "${YELLOW}>> 正在安装/更新 ${FILE_NAME} ...${NC}"
# 使用 apt 直接安装本地 deb 包，可自动补充缺少的系统依赖
sudo apt-get install -y "$TMP_FILE"

# 6. 清理临时缓存文件
rm -rf "$TMP_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  v2rayN ${VERSION} 安装/更新完成！${NC}"
echo -e "${GREEN}  您可以直接在 Ubuntu 应用菜单中搜索 'v2rayN' 打开。${NC}"
echo -e "${GREEN}========================================${NC}"
