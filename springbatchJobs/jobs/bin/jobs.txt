@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  jobs startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Add default JVM options here. You can also use JAVA_OPTS and JOBS_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args
if "%@eval[2+2]" == "4" goto 4NT_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*
goto execute

:4NT_args
@rem Get arguments from the 4NT Shell from JP Software
set CMD_LINE_ARGS=%$

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\jobs.jar;%APP_HOME%\lib\java-client-api-4.0-SNAPSHOT.jar;%APP_HOME%\lib\ml-javaclient-util-2.9.1.jar;%APP_HOME%\lib\ml-junit-2.6.1.jar;%APP_HOME%\lib\core.jar;%APP_HOME%\lib\postgresql-9.4.1208.jre7.jar;%APP_HOME%\lib\spring-batch-core-3.0.7.RELEASE.jar;%APP_HOME%\lib\spring-jdbc-4.2.6.RELEASE.jar;%APP_HOME%\lib\spring-oxm-4.2.6.RELEASE.jar;%APP_HOME%\lib\jena-arq-2.13.0.jar;%APP_HOME%\lib\jena-core-2.13.0.jar;%APP_HOME%\lib\jena-2.6.4.jar;%APP_HOME%\lib\marklogic-jena-1.0.0.jar;%APP_HOME%\lib\json-20160212.jar;%APP_HOME%\lib\commons-cli-1.3.1.jar;%APP_HOME%\lib\ml-app-deployer-2.2.0.jar;%APP_HOME%\lib\jopt-simple-5.0.1.jar;%APP_HOME%\lib\com.ibm.jbatch-tck-spi-1.0.jar;%APP_HOME%\lib\xstream-1.4.7.jar;%APP_HOME%\lib\jettison-1.2.jar;%APP_HOME%\lib\spring-batch-infrastructure-3.0.7.RELEASE.jar;%APP_HOME%\lib\marklogic-xcc-8.0.4.jar;%APP_HOME%\lib\jdom2-2.0.5.jar;%APP_HOME%\lib\jsonld-java-0.5.1.jar;%APP_HOME%\lib\httpclient-cache-4.2.6.jar;%APP_HOME%\lib\libthrift-0.9.2.jar;%APP_HOME%\lib\commons-csv-1.0.jar;%APP_HOME%\lib\commons-lang3-3.3.2.jar;%APP_HOME%\lib\jena-iri-1.1.2.jar;%APP_HOME%\lib\log4j-1.2.17.jar;%APP_HOME%\lib\iri-0.8.jar;%APP_HOME%\lib\icu4j-3.4.4.jar;%APP_HOME%\lib\jaxen-1.1.6.jar;%APP_HOME%\lib\spring-web-4.1.5.RELEASE.jar;%APP_HOME%\lib\javax.batch-api-1.0.jar;%APP_HOME%\lib\xmlpull-1.1.3.1.jar;%APP_HOME%\lib\xpp3_min-1.1.4c.jar;%APP_HOME%\lib\spring-retry-1.1.0.RELEASE.jar;%APP_HOME%\lib\aopalliance-1.0.jar;%APP_HOME%\lib\jersey-client-1.17.jar;%APP_HOME%\lib\jersey-apache-client4-1.17.jar;%APP_HOME%\lib\jersey-multipart-1.17.jar;%APP_HOME%\lib\commons-codec-1.7.jar;%APP_HOME%\lib\jersey-core-1.17.jar;%APP_HOME%\lib\mimepull-1.9.4.jar;%APP_HOME%\lib\mimepull-1.6.jar;%APP_HOME%\lib\spring-beans-4.2.6.RELEASE.jar;%APP_HOME%\lib\spring-core-4.2.6.RELEASE.jar;%APP_HOME%\lib\spring-tx-4.2.6.RELEASE.jar;%APP_HOME%\lib\spring-context-4.1.5.RELEASE.jar;%APP_HOME%\lib\spring-expression-4.1.5.RELEASE.jar;%APP_HOME%\lib\ml-javaclient-util-2.9.0.jar;%APP_HOME%\lib\httpclient-4.3.5.jar;%APP_HOME%\lib\httpcore-4.3.2.jar;%APP_HOME%\lib\xercesImpl-2.11.0.jar;%APP_HOME%\lib\xml-apis-1.4.01.jar;%APP_HOME%\lib\jackson-core-2.6.4.jar;%APP_HOME%\lib\jackson-databind-2.6.4.jar;%APP_HOME%\lib\spring-aop-4.1.5.RELEASE.jar;%APP_HOME%\lib\commons-logging-1.2.jar;%APP_HOME%\lib\java-client-api-3.0.5.jar;%APP_HOME%\lib\logback-classic-1.1.2.jar;%APP_HOME%\lib\logback-core-1.1.2.jar;%APP_HOME%\lib\jackson-annotations-2.6.0.jar;%APP_HOME%\lib\slf4j-api-1.7.6.jar;%APP_HOME%\lib\db2jcc4.jar

@rem Execute jobs
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %JOBS_OPTS%  -classpath "%CLASSPATH%" com.marklogic.spring.batch.Main %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable JOBS_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%JOBS_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
