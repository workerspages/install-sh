# 1. 先安装依赖 ：python -m pip install "requests[socks]"
# 2. 运行脚本   ：python proxy.py

import requests
import concurrent.futures
from requests.exceptions import RequestException
import json

# 1. 定义数据源 (如果 raw.githubusercontent 无法访问，可尝试替换为 raw.kkgithub.com)
URLS = [
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt",
    "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/socks5.txt"
]

# 测试目标（B站API，检测是否被拦截）
TEST_URL = "https://api.bilibili.com/x/web-interface/nav"
TIMEOUT = 5 # 超时时间设短一点，剔除慢速节点

# 增加通用请求头，伪装成正常浏览器，降低被拦截概率
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

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
                    if line.strip():
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
        # 尝试通过代理访问 B站 API，并加上 headers
        resp = requests.get(TEST_URL, proxies=proxies, timeout=TIMEOUT, headers=HEADERS)
        
        # 确保状态码为200，并且能够成功解析为JSON
        if resp.status_code == 200:
            data = resp.json()
            if "code" in data:
                print(f"[可用] {proxy_address} - 延迟: {resp.elapsed.total_seconds():.2f}s")
                return proxy_address
                
    except (RequestException, json.JSONDecodeError):
        # 捕获网络连接超时、断开以及非JSON返回值的异常，忽略这些不可用的代理
        pass
    except Exception as e:
        # 其他未知异常可选择性忽略
        pass
        
    return None

def main():
    proxy_list = get_proxies()
    valid_proxies = []
    
    if not proxy_list:
        print("未获取到任何代理，请检查网络是否能访问 GitHub Raw。")
        return
        
    print("开始并发验证代理连通性 (这可能需要几分钟)...")
    
    # 使用多线程并发验证（设置50个线程）
    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        # 使用 executor.map 会保持输入顺序，适合简单的结果收集
        results = executor.map(check_proxy, proxy_list)
        for res in results:
            if res:
                valid_proxies.append(res)
                
    print("\n--- 验证完成 ---")
    print(f"共找到 {len(valid_proxies)} 个支持访问B站的可用节点。")
    
    # 保存到文件
    if valid_proxies:
        with open("valid_socks5.txt", "w", encoding="utf-8") as f:
            for p in valid_proxies:
                f.write(p + "\n")
        print("已保存至 valid_socks5.txt")

if __name__ == "__main__":
    main()
