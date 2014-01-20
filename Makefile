# Makefile

DEL=del /f
COPY=copy /y
JAVA=java
START=start "test" /B
FLEX_HOME=..\flex_sdk4

MXMLC=$(JAVA) -jar $(FLEX_HOME)\lib\mxmlc.jar +flexlib=$(FLEX_HOME)\frameworks
FDB=$(JAVA) -jar $(FLEX_HOME)\lib\fdb.jar

# Project settings
CFLAGS=-static-rsls -compiler.source-path=.\src\\
CFLAGS_DEBUG=-debug=true
TARGET=main.swf
TARGET_DEBUG=main_d.swf
LIVE_URL=ludumdare.tabesugi.net:public/file/ludumdare.tabesugi.net/ppp/

all: $(TARGET)

clean:
	-$(DEL) $(TARGET) $(TARGET_DEBUG)

update: $(TARGET)
	$(RSYNC) $(TARGET) index.html $(LIVE_URL)

run: $(TARGET)
	$(START) $(TARGET)

debug: $(TARGET_DEBUG)
	$(FDB) $(TARGET_DEBUG)

$(TARGET): .\src\*.as .\assets\*.*
	$(MXMLC) $(CFLAGS) -o $@ .\src\Main.as

$(TARGET_DEBUG): .\src\*.as .\assets\*.*
	$(MXMLC) $(CFLAGS) $(CFLAGS_DEBUG) -o $@ .\src\Main.as
