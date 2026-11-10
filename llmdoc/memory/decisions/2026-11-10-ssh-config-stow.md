# 2026-11-10 ssh 配置纳入 stow（SwiftPM 依赖限速的定稿方案）

## 背景

`git/.gitconfig` 的 `[url "git@github.com:"] insteadOf = https://github.com/` 把 SwiftPM 依赖的 https 地址重写成 SSH，直连 github:22 被限速（18 分钟仅 80MB），git clone 无超时导致 `build-app.sh` 卡死。

## 决策

保留 insteadOf（https 凭证链依赖 gh，当前未登录，删掉后 push 全断），在 `~/.ssh/config` 用 `ProxyCommand nc -X 5 -x 127.0.0.1:7890` 让 SSH 走 Clash。配置文件收入 `ssh/` stow 包（Darwin 专属，含 colima `Include`，在 Linux 上被 OpenSSH 静默忽略），消除重装漂移。

## 验证

- `ssh -T git@github.com` 经代理 5.4s 认证成功。
- `git ls-remote https://github.com/groue/GRDB.swift.git`（被 insteadOf 重写为 SSH）秒级返回。
- TagThings 构建恢复：GRDB 7.11.1 全量 232MB pack 约 2 分钟拉完，`dist/tag-things.app` 产出。
