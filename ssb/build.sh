#!/bin/bash
#
# ./build.sh -Due.env=local-dev package
# ./build.sh -Due.env=dev package
# ./build.sh -Due.env=test package
# ./build.sh -Due.env=prod package
#

if [ -f "../src/1_ssb-v6.1.zip" ]; then
    echo "Moving SSB into the ./components/ssb-v6.1 directory"
	cp ../src/1_ssb-v6.1.zip ./components/ssb-v6.1/ssb-v6.1.zip
else 
	echo "Please place the 1_ssb-v6.1.zip file in the ../src directory of this project"
	exit 1
fi

if [ -f "../src/identityiq-8.0.zip" ]; then
    echo "Moving IdentityIQ 8.0 into the ./components/iiq8.0/base/ga directory"
	cp ../src/identityiq-8.0.zip ./components/iiq8.0/base/ga
else 
	echo "Please place the identityiq-8.0.zip file in the ../src directory of this project"
	exit 1
fi

if [ ! -d build-lib/ant ]; then
    echo "Unzipping Ant from SSBv6.1"
    unzip -q components/ssb-v6.1/ssb-v6.1.zip 'lib/ant/**' -d 'build-lib'
	unzip -qj components/ssb-v6.1/ssb-v6.1.zip 'lib/ant-contrib**' -d 'build-lib'
    mv build-lib/lib/ant build-lib
    rmdir build-lib/lib
    chmod +x build-lib/ant/bin/ant
fi

IS_WIN="$(uname | grep -Ec 'MINGW|Cygwin')"

if [ "$IS_WIN" != "0" ]; then
    build-lib/ant/bin/ant.bat -logger org.apache.tools.ant.listener.ProfileLogger $@
else
    build-lib/ant/bin/ant -logger org.apache.tools.ant.listener.ProfileLogger $@
fi
