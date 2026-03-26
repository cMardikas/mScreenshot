

CC      = gcc
CFLAGS  = -O2 -Wall -Wno-format-truncation
TARGET  = mScreenshot
SRCS    = mScreenshot.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $(SRCS)

clean:
	rm -f $(TARGET)

.PHONY: all clean

