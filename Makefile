ERLANG_PATH=$(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
MAGIC_PATH=/home/linuxbrew/.linuxbrew/include

CFLAGS=-Wall -g -I$(ERLANG_PATH) -I$(MAGIC_PATH)
LDFLAGS=-L$(MAGIC_PATH)/../lib -lmagic

all: priv/magic.so

priv/magic.so: c_src/magic.c
	$(CC) -fPIC -undefined -shared -o $@ $< $(CFLAGS) $(LDFLAGS)
