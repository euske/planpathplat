@set FLEX_HOME=..\flex_sdk4
java -jar %FLEX_HOME%\lib\mxmlc.jar +flexlib=%FLEX_HOME%\frameworks -static-rsls -o main.swf -compiler.source-path=./src src\Main.as
@if errorlevel 1 ( pause
 exit /b )
start /B .\main.swf
