#!/bin/bash
## bash
# @Author: i-curve
# @Date: 2025-09-27 16:01:55
# @Last Modified by: i-curve
# @Name:
##

function check_nginx() {
    if command -v nginx >/dev/null && netstat -lnp | grep -q 80; then
        echo 1 && exit 0
    fi
    echo 0 && exit 1
}

status=$(check_nginx)

if [[ $status = "1" ]]; then
    service nginx stop
fi

"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh"

if [[ $status = "1" ]]; then
    service nginx start
fi
