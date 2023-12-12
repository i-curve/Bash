#!/bin/bash
#!/bin/bash
## bash
# @Author: i-curve
# @Date: 2023-12-12 21:34:01
# @Last Modified by: i-curve
# @Name:
##

if [[ -z "$password" ]]; then
    echo "没有密码, 需要通过 -e password= 方式指定密码." && exit
fi
sed -i 's/"password":.*/"password": ["'$password'"],/g' server.json

./trojan -c server.json
