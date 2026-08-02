# SOCKS5 代理抓取与连通性验证脚本



要执行这个托管在 GitHub 上的 Python 脚本，你需要先将它下载到本地，安装必要的依赖项，然后运行它。

以下是适用于不同操作系统的具体执行步骤：

### Linux / macOS 系统

打开你的终端（Terminal），依次输入以下命令：

```bash
# 1. 下载脚本 (使用 curl 或 wget)
curl -O https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/proxy/proxy.py

# 2. 安装运行所需的依赖 (主要是 requests 和 socks 代理支持)
python3 -m pip install "requests[socks]"

# 3. 运行脚本
python3 proxy.py

```

### Windows 系统

打开命令提示符（CMD）或 PowerShell，依次输入以下命令：

```powershell
# 1. 下载脚本 (Windows 10 及以上系统自带 curl)
curl -o proxy.py https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/proxy/proxy.py

# 2. 安装运行所需的依赖
python -m pip install "requests[socks]"

# 3. 运行脚本
python proxy.py

```

---

### ⚠️ 安全建议

在执行任何直接从网络上下载的脚本之前，良好的习惯是先查看一下它的源代码。你可以用记事本（Windows）、`cat proxy.py`（Linux/Mac）或直接在浏览器中打开那个 URL，确认其中没有恶意代码后再执行。
