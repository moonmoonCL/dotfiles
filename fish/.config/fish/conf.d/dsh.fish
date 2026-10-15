# DeepSeek dsh（官方指令：npx @deepseek-ai/dsh web）的后台起停
# WHY：web 服务是常驻进程，放后台不占终端；nohup + 重定向让它在终端关闭后继续
# 存活，输出落 /tmp/dsh-web.log（含带 token 的访问地址）；npx -y 跳过首次下载的
# 交互确认（后台运行时无法按 y，不加会永久卡住）。
# 版本跟随 latest 渠道（显式写 @latest）：该包所有发布都是 alpha/rc 预发布、
# 没有正式版，维护者把推荐版本挂在 latest tag、最前沿挂在 alpha tag；
# npx 每次启动重新解析，新 latest 发布后下次 `dsh` 自动用上。
# 某版出问题需要临时固定时，把 @latest 换成 @版本号 即可。
# 注意：真正干活的 server 是 npx 拉起的 node，cmdline 不含包名（形如
# node .../node_modules/.bin/dsh web），起停检测都按这个特征匹配；杀掉 server
# 后 npm/sh 父进程会自行退出。不要用 `pkill -f @deepseek-ai/dsh`——任何
# 命令行里恰好含包名字符串的进程（grep/包装脚本）都会被误杀。

function __dsh_running
    if test -f /tmp/dsh-web.pid; and ps -p (cat /tmp/dsh-web.pid) >/dev/null 2>&1
        return 0
    end
    pgrep -f 'node_modules/\.bin/dsh web' >/dev/null 2>&1
end

function dsh -d "后台启动 DeepSeek dsh web"
    if __dsh_running
        echo "dsh 已在运行，访问地址见 /tmp/dsh-web.log"
        return 0
    end
    nohup npx -y @deepseek-ai/dsh@latest web >/tmp/dsh-web.log 2>&1 &
    echo $last_pid >/tmp/dsh-web.pid
    echo "dsh 已后台启动（PID $last_pid），日志：/tmp/dsh-web.log"
end

function dsh-stop -d "停止后台 dsh web"
    set -l found 0
    if pgrep -f 'node_modules/\.bin/dsh web' >/dev/null 2>&1
        pkill -f 'node_modules/\.bin/dsh web'
        set found 1
    end
    # 下载阶段 server 尚未拉起，此时杀 npm 父进程来中止
    if pgrep -f 'npm exec @deepseek-ai/dsh' >/dev/null 2>&1
        pkill -f 'npm exec @deepseek-ai/dsh'
        set found 1
    end
    rm -f /tmp/dsh-web.pid
    if test $found -eq 1
        echo "dsh 已停止"
    else
        echo "dsh 未在运行"
        return 1
    end
end
