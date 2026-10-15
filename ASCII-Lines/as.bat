@echo off

set file=%1
set option=
set binfile=%file%.bin

if "%1"=="" goto end    

echo -------- %file% -----------

set bin=C:\8Bit\as\bin
%bin%\asw.exe -L %file%.asm -a "" -w -U 
%bin%\p2bin.exe -r $-$ "%file%.p" "%binfile%"
%bin%\plist.exe "%file%.p" 

del %file%.inc
del %file%.p
del %file%.lst
exit /B

:end
echo "use: as <file>"
exit /B