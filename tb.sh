#!/bin/bash

if ! [ "$(uname)" == "Linux" ]; then
    echo "不支持的操作系统: $(uname)"
    exit 1
fi

do_start(){
    docker compose up -d
}
do_stop(){
    docker compose up -d
}
do_restart(){
    do_start
    do_stop
}
do_logs(){
    docker compose logs -f
}
do_update(){
    docker compose pull
    do_restart
}

case $1 in
    start|s|up)
        do_start
        ;;
    stop|s|down)
        do_stop
        ;;
    restart|r)
        do_restart
        ;;
    logs|l)
        do_logs
        ;;
    update|u)
        do_update
        ;;
    login|l)
        echo ":: 登录完成后按下 Ctrl+C 以退出登录流程"
        echo ":: 执行 $0 start 启动"
        touch .env config.json
        mkdir plugins assets
        docker compose run -it --rm telebox
        ;;
    *)
        echo "$0 {start|up|stop|down|restart|login|update|logs}
:: 启动 start | up
:: 停止 stop | down
:: 重启 restart
:: 日志 logs
:: 更新 update
:: 登录 login"
        ;;
esac