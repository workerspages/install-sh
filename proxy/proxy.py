# 1. 先安装依赖 ：python -m pip install "requests[socks]"
# 2. 运行脚本   ：python proxy.py

import requests
import concurrent.futures

# 1. 定义数据源
URLS = [
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt",
    "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/socks5.txt"
]

# 测试目标（B站API，检测是否被拦截）
TEST_URL = "https://api.bilibili.com/x/web-interface/nav"
TIMEOUT = 5 # 超时时间设短一点，剔除慢速节点

def get_proxies():
    print("正在从网络获取代理列表...")
    proxies = set()
    for url in URLS:
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                # 按行分割，提取IP:PORT
                lines = response.text.strip().split('\n')
                for line in lines:
                    if line:
                        proxies.add(line.strip())
        except Exception as e:
            print(f"获取 {url} 失败: {e}")
    print(f"共获取到 {len(proxies)} 个去重后的节点。")
    return list(proxies)

def check_proxy(proxy_address):
    # 构造 requests 代理格式
    proxies = {
        "http": f"socks5://{proxy_address}",
        "https": f"socks5://{proxy_address}"
    }
    try:
        # 尝试通过代理访问 B站 API
        resp = requests.get(TEST_URL, proxies=proxies, timeout=TIMEOUT)
        if resp.status_code == 200 and "code" in resp.json():
            print(f"[可用] {proxy_address} - 延迟: {resp.elapsed.total_seconds():.2f}s")
            return proxy_address
    except:
        pass
    return None

def main():
    proxy_list = get_proxies()
    valid_proxies = []
    
    print("开始并发验证代理连通性 (这可能需要几分钟)...")
    # 使用多线程并发验证（设置50个线程加快速度）
    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        results = executor.map(check_proxy, proxy_list)
        for res in results:
            if res:
                valid_proxies.append(res)
                
    print("\n--- 验证完成 ---")
    print(f"共找到 {len(valid_proxies)} 个支持访问B站的可用节点。")
    
    # 保存到文件
    if valid_proxies:
        with open("valid_socks5.txt", "w") as f:
            for p in valid_proxies:
                f.write(p + "\n")
        print("已保存至 valid_socks5.txt")

if __name__ == "__main__":
    main()
