@echo off
REM Migrate Tivoli endoint to TMR specified as argument
if %1. == . goto USAGE
    echo # Migrating endpoint to TMR: %1
    echo net stop lcfd
    net stop lcfd
    echo lcs.login_interfaces=%1+9494 ^>^> last.cfg
    echo lcs.login_interfaces=%1+9494 >> last.cfg
    echo del /f last.cfg.bak lcf.dat lcf.dat.bak lcfd.log
    del /f last.cfg.bak lcf.dat lcf.dat.bak lcfd.log
    echo net start lcfd
    net start lcfd
    goto END
:USAGE
    echo Must supply TMR FQDN or IP address as argument
:END
