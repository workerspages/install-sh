## sing-box四合一键安装脚本

```bash
bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/sing-box.sh)
```
    
无交互一键快速安装：
```bash
bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/sing-box.sh) -i
```
    
温馨提示：NAT小鸡需带可用端口范围内的端口运行，或运行完后修改reality、hy2、tuic三个直连端口和订阅端口
    
例如：
```bash
PORT=8888 bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/sing-box.sh)
```
    
快捷指令和命令行
进入菜单快捷指令: `sb`
查看节点信息和订阅:  `sb -c`
一键卸载:   `sb -u`



## 只安装节点使用这个(等于号后面的值改为自己的,变量之间有空格)：
```bash
ARGO_DOMAIN=argo.xxx.xx ARGO_AUTH=eyxxx bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/sbx.sh)
```

安装哪吒+节点使用这个(哪吒和隧道变量也需要改为自己的,变量之间有空格)：
```bash
NEZHA_SERVER=nezha.xxx.com:8008 NEZHA_KEY=xxx ARGO_DOMAIN=aargo.xxx.xx ARGO_AUTH=eyxxx bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/sbx.sh)
```

一键卸载命令：
```bash
bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/sbx.sh) -u
```

安装在线SSH终端(ARGO_PORT默认8080):
```bash
ARGO_PORT=8080 ARGO_DOMAIN=ssh.xxx.xx ARGO_AUTH=eyxxx bash <(curl -Ls https://raw.githubusercontent.com/workerspages/install-sh/refs/heads/main/laowang/gotty.sh)
```
