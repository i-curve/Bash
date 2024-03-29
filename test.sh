#!/bin/bash
## bash
# @Author: curve
# @Date: 2021-03-01 17:41:01
# @Last Modified by: curve
# @Last Modified time: 2021-12-14 23:25:34
##

source "$(dirname $0)/util/util.sh"

arr=(github.com raw.githubusercontent.com gist.github.com api.github.com)
function error() {
    red "错误信息: $1无法访问"
    yellow "********************************************************"
    echo "由于脚本一些内容需要在github上下载配置,但是检测到一些github一些域"
    echo "名无法使用, 这可能导致部分脚本无法正常运行"
    echo "请复制 https://github.com/i-curve/content/blob/master/githubhosts"
    echo "以上的内容到本机hosts再次尝试"
    yellow "********************************************************"
}
function test() {
    echo "测试$1"
    temp=$(curl -s "$1" --connect-timeout 10)
    if [[ $? != 0 ]]; then
        error $1
        exit 0
    fi
}
function start() {
    clear
    echo "测试脚本启动"
    echo "请不要急着关闭本脚本"
    echo "--------------------"
    country=$(GetIPCountry)
    echo "当前ip所在国家: ${country}"
    for name in ${arr[@]}; do
        test $name
    done
    echo "一切完美"
}

start
