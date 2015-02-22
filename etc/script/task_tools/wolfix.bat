@echo off
set
cd %LCF_DATDIR%
find "wol_enable" last.cfg
if errorlevel==1 goto addwol
goto end
:addwol
echo wol_enable=1 >> last.cfg
goto end
:end
