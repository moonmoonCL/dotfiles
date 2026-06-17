function sson
    set -gx http_proxy http://127.0.0.1:7890
    set -gx https_proxy http://127.0.0.1:7890
    set -gx all_proxy socks5://127.0.0.1:7890
    set -gx no_proxy localhost,127.0.0.1,::1

    echo "Proxy enabled"
end

function ssoff
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e no_proxy

    echo "Proxy disabled"
end

# 启动时自动开启代理
sson
