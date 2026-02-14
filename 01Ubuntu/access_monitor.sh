#!/bin/bash
# WireGuard 客户端 IP 监控脚本（抓取第二行的客户端 IP）
# 日志保存路径
RECORD_FILE="/var/log/access_records.log"

# 确保日志文件存在且所有用户可写
if [ ! -f "$RECORD_FILE" ]; then
    sudo touch "$RECORD_FILE"
    sudo chmod 666 "$RECORD_FILE"  # 彻底解决权限问题
fi

# 函数：抓取 WireGuard 客户端 IP（提取第二行的客户端 IP）
get_wg_ip() {
    # 检查 wg 命令是否存在
    if ! command -v wg &> /dev/null; then
        error_time=$(date +%Y-%m-%d\ %H:%M:%S)
        echo -e "\n------------------------------
监控时间：$error_time
错误：未安装 WireGuard（wg 命令不存在）
------------------------------\n" >> "$RECORD_FILE"
        return
    fi

    # 检查 wg0 接口是否存在
    if ! sudo wg show wg0 &> /dev/null; then
        error_time=$(date +%Y-%m-%d\ %H:%M:%S)
        echo -e "\n------------------------------
监控时间：$error_time
错误：WireGuard 接口 wg0 不存在
------------------------------\n" >> "$RECORD_FILE"
        return
    fi

    # 核心：提取第二行的内容（跳过第一行接口信息，取第二行peer信息）
    # sed -n '2p' 表示只取第二行；IFS=$'\t' 按制表符拆分列
    second_line=$(sudo wg show wg0 dump | sed -n '2p')
    if [ -n "$second_line" ]; then
        IFS=$'\t' read -r -a columns <<< "$second_line"
        
        # 先确认你要的 IP 所在列（默认 endpoint 在第三列，索引 2，可根据实际调整）
        endpoint_full=${columns[2]}  # 这里是第二行的第三列（endpoint 列），可按需改索引
        
        # 只处理非 (none) 的有效 IP 地址
        if [ "$endpoint_full" != "(none)" ] && [[ "$endpoint_full" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
            # 提取 IP 部分（去掉端口）
            endpoint_ip=$(echo "$endpoint_full" | cut -d':' -f1)
            
            # 构造带分隔线的记录
            record_time=$(date +%Y-%m-%d\ %H:%M:%S)
            record_content="
------------------------------
监控时间：$record_time
WireGuard 客户端 IP：$endpoint_ip
------------------------------
"
            # 写入日志
            echo -e "$record_content" >> "$RECORD_FILE"
            echo "" >> "$RECORD_FILE"
            
            # 终端打印调试信息
            echo "✅ 成功抓取第二行的客户端 IP：$endpoint_ip"
            return  # 抓取到后直接返回，避免执行后续空提示
        fi
    fi

    # 无有效 IP 时的提示（方便排查）
    empty_time=$(date +%Y-%m-%d\ %H:%M:%S)
    echo -e "\n------------------------------
监控时间：$empty_time
提示：未检测到有效 WireGuard 客户端连接（第二行无有效 IP）
------------------------------\n" >> "$RECORD_FILE"
    echo "ℹ️  未检测到有效客户端 IP（第二行无有效内容），已写入提示到日志"
}

# 主逻辑：每30秒循环抓取一次
while true; do
    echo -e "\n🔍 开始新一轮抓取（当前时间：$(date)）"
    get_wg_ip
    sleep 30
done