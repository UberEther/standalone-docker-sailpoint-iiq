@echo off
rem
rem build.bat -Due.env=local-dev package
rem build.bat -Due.env=dev package
rem build.bat -Due.env=test package
rem build.bat -Due.env=prod package
rem
rem Powershell command based on http://stackoverflow.com/questions/17546016/how-can-you-zip-or-unzip-from-the-command-prompt-using-only-windows-built-in-ca
rem

if EXIST build-lib\ant GOTO RUN_SSB

echo "Unzipping Ant"
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('build-lib/apache-ant-1.10.10-bin.zip', 'build-lib'); }"
ren build-lib\apache-ant-1.10.10 build-lib\ant

:RUN_SSB
build-lib\ant\bin\ant.bat -logger org.apache.tools.ant.listener.ProfileLogger %*
