function sson
    set -x http_proxy http://127.0.0.1:7890
    set -x https_proxy http://127.0.0.1:7890
    set -x all_proxy socks5://127.0.0.1:7890
    set -x no_proxy localhost,127.0.0.1,::1

    echo "Proxy enabled"
end

function ssoff
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e no_proxy

    echo "Proxy disabled"
end
