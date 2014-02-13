# Makefile

SEP=\\
DEL=del /f
COPY=copy /y
RM=rm -f
CP=cp -f
JAVA=java
START=start "test" /B
RSYNC=rsync -av

FLEX_HOME=..$(SEP)flex_sdk4
MXMLC=$(JAVA) -jar $(FLEX_HOME)$(SEP)lib$(SEP)mxmlc.jar +flexlib=$(FLEX_HOME)$(SEP)frameworks
FDB=$(JAVA) -jar $(FLEX_HOME)$(SEP)lib$(SEP)fdb.jar
CFLAGS=-static-rsls
CFLAGS_DEBUG=-debug=true

# Project settings
TARGET=main.swf
TARGET_DEBUG=$(TARGET)_d.swf

all: $(TARGET)

clean:
	-$(DEL) $(TARGET) $(TARGET_DEBUG)

run: $(TARGET)
	$(START) $(TARGET)

debug: $(TARGET_DEBUG)
	$(FDB) $(TARGET_DEBUG)

$(TARGET): .$(SEP)src$(SEP)*.as
	$(MXMLC) $(CFLAGS) -compiler.source-path=.$(SEP)src$(SEP) \
		-o $@ .$(SEP)src$(SEP)Main.as

$(TARGET_DEBUG): .$(SEP)src$(SEP)*.as
	$(MXMLC) $(CFLAGS) $(CFLAGS_DEBUG) -compiler.source-path=.$(SEP)src$(SEP) \
		-o $@ .$(SEP)src$(SEP)Main.as

LIVE_URL=ludumdare.tabesugi.net:public/file/ludumdare.tabesugi.net/ppp/
update: $(TARGET)
	$(RSYNC) $(TARGET) index.html $(LIVE_URL)
