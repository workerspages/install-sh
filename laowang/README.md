sing-box四合一键安装脚本
    
bash <(curl -Ls https://raw.githubusercontent.com/eooce/sing-box/main/sing-box.sh)
    
无交互一键快速安装：
bash <(curl -Ls https://raw.githubusercontent.com/eooce/sing-box/main/sing-box.sh) -i
    
温馨提示：NAT小鸡需带可用端口范围内的端口运行，或运行完后修改reality、hy2、tuic三个直连端口和订阅端口
    
例如：
PORT=8888 bash <(curl -Ls https://raw.githubusercontent.com/eooce/sing-box/main/sing-box.sh)
    
快捷指令和命令行
进入菜单快捷指令: sb
查看节点信息和订阅:  sb -c
一键卸载:   sb -u
