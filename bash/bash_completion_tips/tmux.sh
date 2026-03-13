# 通过tmux.sh启动某个会话,需要name
# name后面跟启动脚本, 启动脚本可为空, 空白启动bash等默认终端
tmux.sh start {name} {-completion}

# 连接到某个会话 
tmux.sh attach {cmd:activity_session} 

# 显示会话
# --all 表示显示被关闭的会话
tmux.sh list --all                      List sessions

# 打印某个会话日志, -f 表示像tail -f一样跟踪, 100为显示行数, 默认50
tmux.sh logs {cmd:activity_session} -f 50
# 打印某个会话日志, -t 显示后就关闭, 不持续输出 
tmux.sh logs {cmd:activity_session} -t 50
# --raw表示带有显示带有 ANSI 序列的原始日志（可能会影响终端）
tmux.sh logs {cmd:activity_session} --raw -f 50
tmux.sh logs {cmd:activity_session} --raw -t 50
# --raw表示带有显示带有 ANSI 序列的原始日志（可能会影响终端）
tmux.sh logs {cmd:activity_session} --raw -f 50
tmux.sh logs {cmd:activity_session} --raw -t 50

# 不记录发送的日志
tmux.sh send {cmd:activity_session} {message} --ignore-log 
# 不发送回车
tmux.sh send {cmd:activity_session} {message} --no-enter 
# 回车更消息分开发送, 用于特定的交互式命令真实的发送消息
tmux.sh send {cmd:activity_session} {message} --separate-enter


# --force强行停止会话一般都需要
tmux.sh stop {cmd:activity_session} --force

# 分割日志
tmux.sh part-log {cmd:activity_session}

# 清理所有日志, --dry-run 表示只是尝试不实际执行
tmux.sh clean 0 --dry-run

