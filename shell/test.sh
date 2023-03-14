#!/bin/bash
## bash
# @Author: curve
# @Date: 2023-03-14 10:37:59
# @Last Modified by: curve
# @Name: test script
##
set -e

# shellcheck source=../util/util.sh
source "$(dirname $0)/../util/util.sh"

echo "filename: ${filename}"
echo "dir: ${filepath}"

echo "核对系统: "
UtilCheck

echo "pkg source: $systemPackage"

sleep 2
echo "test common header: "
UtilEchoHead "test script"

echo "get local ip country"
GetIPCountry
