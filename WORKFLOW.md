# 工作流实战：用 test 项目走一遍

用一个虚构的 `~/Workspace/test` 项目，从打开终端到合并收工，把整套工作流串起来。快捷键速查见 [USAGE.md](USAGE.md)。

场景：今天要做两件事——修一个登录 bug、加一个 CSV 导出功能。两件事都交给 agent 并行做，自己同时改文档。

---

## 1. 进入项目

打开 Ghostty，一条命令进入（或切回）项目专属的 tmux session：

```
ts
```

fzf 列出 zoxide 记录的目录，敲 `test` 回车——自动创建（或切换到）名为 `test` 的 session，工作目录就在项目里。以后无论在哪，`ts` 选 `test` 都能一键回到这个现场。

> 第一次去这个项目？先 `z test`（或 `cd ~/Workspace/test`）让 zoxide 记住它，之后就有了。

> 同时维护多个 Tipsy 服务或 worktree 时，运行 `tipsy`。列表会显示服务名、分支、`clean`/`dirty` 状态、开放 PR 和路径；选中后直接进入对应目录。用 `tipsy --list` 只查看清单。

## 2. 搭好自己的工位

当前 window 就是"主工位"。按 `Prefix + W` 展开 IDE 布局：左边 75% 主区开 `vim`（LazyVim），右侧堆叠的小 pane 留给命令行和 `y`（Yazi 浏览文件）。

`Ctrl + h/j/k/l` 在 nvim 分屏和 tmux pane 之间无缝移动，不用想"我现在在哪一层"。

## 3. 派出两个 agent

**任务一：修登录 bug。**

```
wt fix-auth
```

一条命令干了三件事：建分支 `fix-auth`、建 worktree `~/worktrees/test/fix-auth`、开同名 tmux window 并跳入。在里面起 agent：

```
claude "修复登录时 token 过期不跳转登录页的 bug，补上对应测试"
```

**任务二：CSV 导出。** `Option + 1` 跳回主 window，再来一次：

```
wt feat-export
claude "给报表页加 CSV 导出按钮，后端加对应接口"
```

现在状态栏是：`1: main  2: fix-auth  3: feat-export`。两个 agent 在各自的 worktree 里改同一个仓库，物理隔离、互不干扰。

## 4. 回自己的活，等被叫

`Option + 1` 回主工位改文档。不用盯着 agent——它们停下来时会主动找你：

- **人在终端**：停下的 agent 所在 window 名在状态栏**变黄**。
- **人在浏览器查资料**：macOS 右上角弹通知，标题区分「需要确认」（agent 等你拍板）和「任务完成」。

通知来了，`Option + 2` 跳过去。如果是 agent 在等确认，看一眼它要干嘛、回复一句，再跳回来——不用等它跑完。

## 5. 审查 agent 的活

`fix-auth` 报告完成。跳到 window 2，按 `Prefix + g`——lazygit 浮窗弹出，自动就在这个 worktree 里，delta 渲染的 diff 逐行审查 agent 的改动。

- 改得好：在 lazygit 里 `Space` stage、`c` commit，`q` 关浮窗。
- 有问题：`q` 关掉浮窗，直接在这个 window 里继续跟 agent 对话让它改，或者 `vim` 自己上手（worktree 就是普通目录）。

## 6. 合并

回主 window（`Option + 1`），确认在 main 分支上：

```
git merge fix-auth
```

`feat-export` 完成后同样走一遍 5-6。两个任务从头到尾没碰过对方的文件，合并时才见面。

## 7. 收尾

```
wtd fix-auth
wtd feat-export
```

删掉 worktree 和分支。`wtd` 用的是 `branch -d`——**没合并的分支会拒绝删除**，不怕手滑丢掉 agent 的成果。window 2、3 用 `Prefix + x` 关掉。

最后 `lg`（或 `Prefix + g`）确认工作区干净，`P` 推送。

## 8. 离开

`Prefix + d` detach——session 还活着，tmux-resurrect 每 10 分钟自动存档。明天打开 Ghostty，`ts` 选 `test`，现场原样回来。

---

## 一天的动作总结

| 动作 | 按键/命令 |
|--------|--------|
| 进项目 | `ts` |
| 摆工位 | `Prefix + W` |
| 派任务 | `wt <任务名>` → `claude "..."` |
| 谁在等我 | 看黄色 window 名 / macOS 通知 |
| 切任务 | `Option + 数字` |
| 审查 | `Prefix + g`（lazygit + delta） |
| 合并 | 主 window 里 `git merge <任务名>` |
| 收尾 | `wtd <任务名>`，`Prefix + x` 关 window |
| 下班 | `Prefix + d` |
