#!/bin/bash

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
version_local=$(cat ./version|grep version|cut -d' ' -f2)
red "Don't stop it,detect the new version...."
version_hub=$(curl -s https://raw.githubusercontent.com/i-curve/Bash/master/version|grep version|cut -d' ' -f2)

if [ $version_local = $version_hub ];then
		green "the version is latest"
else
		red "detect the new version"
		red "it will be update..."
		git pull https://github.com/i-curve/Bash.git
		green "update OK"
fi

