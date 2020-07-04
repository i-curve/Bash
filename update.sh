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
function local_version(){
version_local=$(cat ./version|grep version|cut -d' ' -f2)
}
function hub_version(){
version_hub=$(curl -s https://raw.githubusercontent.com/i-curve/Bash/master/version|grep version|cut -d' ' -f2)
}
function update(){
local_version
red "Don't stop it,detect the new version...."
hub_version
if [ $version_local = $version_hub ];then
		green "the version is latest"
else
		red "detect the new version"
		red "it will be update..."
		git pull https://github.com/i-curve/Bash.git
		green "update OK"
fi
}
start(){
		clear
		green "============================="
		green "Author:curve"
		green "Shell:the package update shell"
		green "OS:centos7+/debian9+/ubuntu16.04+"	
		green "============================="
		echo
		green "============================="
		red "1.detect the local version"
		green "============================="
		red "2.detect the latest version"
		green "============================="
		red "3.update the package"
		green "============================="
		red "0.exit"
		green "============================="
		echo
		read -p "please input the number:" num
		case "$num" in
				1)
					local_version
					echo "the version is"
					red "$version_local"
					;;
			2)
					hub_version
					echo "the version is"
					red "$version_hub"
					;;
			3)
					update
					;;
			0)
					exit 0;
					;;
			*)
					red "please input the right num"
					sleep 1
					start
					;;
	esac

}
start
