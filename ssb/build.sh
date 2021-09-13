#!/bin/bash
#
# ./build.sh -Due.env=local-dev package
# ./build.sh -Due.env=dev package
# ./build.sh -Due.env=test package
# ./build.sh -Due.env=prod package
#

if [ ! -d build-lib/ant ]; then
    echo "Unzipping Ant"
    unzip -q build-lib/apache-ant-1.10.10-bin.zip -d 'build-lib'
    mv build-lib/apache-ant-1.10.10 build-lib/ant
    chmod +x build-lib/ant/bin/ant
fi

IS_WIN="$(uname | grep -Ec 'MINGW|Cygwin')"

if [ "$IS_WIN" != "0" ]; then
    build-lib/ant/bin/ant.bat $@
else
    build-lib/ant/bin/ant $@
fi
