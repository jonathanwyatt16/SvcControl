@ECHO off
SETLOCAL EnableDelayedExpansion

SET command=%3
IF "%command%"=="start" GOTO :SvcControl_start
IF "%command%"=="stop" GOTO :SvcControl_stop
IF "%command%"=="status" GOTO :SvcControl_status
IF "%command%"=="enable" GOTO :SvcControl_enable
IF "%command%"=="disable" GOTO :SvcControl_disable
IF "%command%"=="info" GOTO :SvcControl_info

:SvcControl_help
ECHO.
ECHO DESCRIPTION:
ECHO 	SvcControl starts, stops, or prints the status of a list 
ECHO 	of services on a list of servers.
ECHO.	 
ECHO USAGE:
ECHO 	SvcControl [server list] [service list] [command]
ECHO 	EX: SvcControl servers.txt services.txt start
ECHO.
ECHO 	ARGUMENTS:
ECHO 	[server list]-----.txt file with hostnames of servers to target.
ECHO 	[service list]----.txt file with names of services to target.
ECHO 	[command]---------One of the following six commands.
ECHO.
ECHO 	COMMANDS:
ECHO 	start-------------Start the service.
ECHO 	stop--------------Stop the service.
ECHO 	status------------Print the status of the service.
ECHO 	enable------------Set the service start type to disabled.
ECHO 	disable-----------Set the service start type to auto.
ECHO 	info--------------Print the start type and max memory of the service.
GOTO :EOF

:SvcControl_start
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		ECHO Starting %%B on %%A
		sc \\%%A start %%B > NUL
	)
)
GOTO :SvcControl_status

:SvcControl_stop
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		ECHO Stopping %%B on %%A
		sc \\%%A stop %%B > NUL
	)
)
GOTO :SvcControl_status

:SvcControl_status
ECHO.
ECHO SERVER              SERVICE             STATUS
ECHO ------              -------             ------
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		SET "svr=%%A                                  "
		SET "svr=!svr:~0,20!"
		SET "svc=%%B                                  "
		SET "svc=!svc:~0,20!"
		
		SET "ste=Not Found" 
		FOR /f "tokens=1-3 delims=: " %%C IN ('sc \\%%A query %%B') DO (
			IF %%C==STATE (
				SET "ste=%%E"	
			)
		)
		
		ECHO !svr!!svc!!ste!
	)
)
GOTO :EOF

:SvcControl_enable
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		ECHO Enabling %%B on %%A
		sc \\%%A config %%B start=auto> NUL
	)
)
GOTO :SvcControl_info

:SvcControl_disable
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		ECHO Disabling %%B on %%A
		sc \\%%A config %%B start=disabled> NUL
	)
)
GOTO :SvcControl_info

:SvcControl_info
ECHO.
ECHO SERVER              SERVICE             START TYPE          MAX MEMORY (MB)
ECHO ------              -------             ----------          ---------------
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		SET "svr=%%A                                  "
		SET "svr=!svr:~0,20!"
		SET "svc=%%B                                  "
		SET "svc=!svc:~0,20!"
		
		SET "stt=Not Found           "
		FOR /f "tokens=1-3 delims=: " %%C IN ('sc \\%%A qc %%B') DO (
			IF %%C==START_TYPE (
				SET "stt=%%E                                  "
				SET "stt=!stt:~0,20!"
			)
		)
		
		SET "mm=Not Found"
		FOR /f "tokens=3" %%D IN ('REG QUERY "\\%%A\HKLM\SOFTWARE\Wow6432Node\Apache Software Foundation\Procrun 2.0\%%B\Parameters\Java" /v JvmMx 2^>NUL') DO (
			set /a "mm=%%D"
		)

		ECHO !svr!!svc!!stt!!mm!
	)
)
ENDLOCAL
