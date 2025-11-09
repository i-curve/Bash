#!/bin/bash
# @Date: 2025-11-09 23:21:54
# @Last Modified by: i-curve
# @Name:
##
if ps aux | grep '[n]ginx' >/dev/null; then
        isRunning=1
else
        isRunning=0
fi

if [[ "$isRunning" == "1" ]]; then
        service nginx stop
fi
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" >/dev/null
if [[ "$isRunning" == "1" ]]; then
        service nginx start
fi