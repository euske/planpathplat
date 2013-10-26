# Makefile

RM=rm -f
CP=cp -f
CHMOD=chmod
RSYNC=rsync -av
JAVA=java
FLEX_HOME=../flex_sdk4
MXMLC=$(JAVA) -jar $(FLEX_HOME)/lib/mxmlc.jar +flexlib=$(FLEX_HOME)/frameworks
FDB=$(JAVA) -jar $(FLEX_HOME)/lib/fdb.jar

# Project settings
CFLAGS=-static-rsls -debug=true
TARGET=main.swf
LIVE_URL=ludumdare.tabesugi.net:public/file/ludumdare.tabesugi.net/ppp/

all: $(TARGET)

clean:
	-$(RM) $(TARGET)

update: $(TARGET)
	$(RSYNC) $(TARGET) index.html $(LIVE_URL)

debug: $(TARGET)
	$(FDB) $(TARGET)

$(TARGET): ./src/*.as ./assets/*.png 
	$(MXMLC) $(CFLAGS) -compiler.source-path=./src/ -o $@ ./src/Main.as
	$(CHMOD) +x $(TARGET)
