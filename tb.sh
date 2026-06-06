#!/bin/bash

if ! [ "$(uname)" == "Linux" ]; then
    echo "不支持的操作系统: $(uname)"
    exit 1
fi

case $1 in
    start)
        docker compose up -d
        ;;
    stop)
        docker compose down
        ;;
    restart)
        docker compose down
        docker compose up -d
        ;;
    logs)
        docker compose logs -f
        ;;
    update)
        echo ":: 更新后需 $0 restart 以应用更新"
        docker compose pull
        ;;
    login)
        echo ":: 登录完成后按下 Ctrl+C 以退出登录流程"
        echo ":: $0 start 启动"
        touch .env config.json
        mkdir plugins assets
        docker compose run -it --rm telebox
        ;;
    *)
        echo "$0 {start|stop|restart|login|update|logs}"
        ;;
esac