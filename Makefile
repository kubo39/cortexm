.PHONY: all clean

LDC = ldc2
LD = arm-none-eabi-ld
AS = arm-none-eabi-as

TARGET = libcortexm.a

OBJDIR = out

SRCS = \
	$(shell find ./source -name "*.d") \

LDCFLAGS = -mtriple=thumbv7em-none-linux-gnueabihf -betterC -defaultlib= -Os -release -g -lib -od=$(OBJDIR) -of$(TARGET)

LINKFLAGS = \
	-I./source

all: $(TARGET)

$(TARGET): $(SRCS)
	$(LDC) $(LDCFLAGS) -op ${LINKFLGAS} $^

clean:
	$(RM) -r $(OBJDIR)/* $(TARGET)
