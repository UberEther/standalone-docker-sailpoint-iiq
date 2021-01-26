#!/bin/bash
#
# ./build.sh -Due.env=local-dev package
# ./build.sh -Due.env=dev package
# ./build.sh -Due.env=test package
# ./build.sh -Due.env=prod package
#

if [ ! -d build-lib/ant ]; then
    echo "Unzipping Ant from SSB"
    unzip -q components/ssb-v6.1/ssb-v6.1.zip 'lib/ant/**' -d 'build-lib'
    mv build-lib/lib/ant build-lib
    rmdir build-lib/lib
    chmod +x build-lib/ant/bin/ant
fi

IS_WIN="$(uname | grep -Ec 'MINGW|Cygwin')"

if [ "$IS_WIN" != "0" ]; then
    build-lib/ant/bin/ant.bat $@
else
    build-lib/ant/bin/ant $@
fi
