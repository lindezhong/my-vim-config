
# 打印活跃可用的session
function activity_session() {
    tmux.sh list | awk '{print $2}' | tail -n +3
}


