@echo off

set file=%1
set option=
set binfile=%file%.com

if "%1"=="" goto end    
if "%2" NEQ "" (
        set binfile="%file%_%2.bin"
        set option="-D BASE=%2"
)

echo -------- %file% -----------

set bin=C:\8Bit\as\bin
rem %bin%\asw.exe -L %file%.asm -a "%option%" -w -U -E msg.txt
%bin%\asw.exe -L %file%.asm -a "" -w -U 
%bin%\p2bin.exe -r $-$ "%file%.p" "%binfile%"
%bin%\plist.exe "%file%.p" 

del %file%.inc
del %file%.p
rem del %file%.lst
exit /B

:end
echo "use: as <file> [<ORG>]   e.g. ORG:= 8000H"
exit /B