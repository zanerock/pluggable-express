NPM_BIN:=$(shell npm bin)
CATALYST_SCRIPTS:=$(NPM_BIN)/catalyst-scripts
BASH_ROLLUP:=$(NPM_BIN)/bash-rollup

LIQ_SERVER_SRC:=src/liq-server
LIQ_SERVER_FILES:=$(shell find $(LIQ_SERVER_SRC) -name "*.js" -not -path "*/test/*" -not -name "*.test.js")
LIQ_SERVER_TEST_SRC_FILES:=$(shell find $(LIQ_SERVER_SRC) -name "*.js")
LIQ_SERVER_TEST_BUILT_FILES=$(patsubst $(LIQ_SERVER_SRC)/%, test-staging/%, $(LIQ_SERVER_TEST_SRC_FILES))
LIQ_SERVER_TEST_SRC_DATA:=$(shell find $(LIQ_SERVER_SRC) -path "*/data/*" -type f)
LIQ_SERVER_TEST_BUILT_DATA:=$(patsubst $(LIQ_SERVER_SRC)%, test-staging/%, $(LIQ_SERVER_TEST_SRC_DATA))
LIQ_SERVER_BIN:=dist/liq-server.js

CLI_SRC=src/cli
CLI_SRC_ROOT:=$(CLI_SRC)/liq-server.sh
CLI_SRC_FILES:=$(shell find $(CLI_SRC) -not -name "$(notdir $(CLI_SRC_ROOT))")
CLI_BIN:=dist/liq-server.sh

BUILD_TARGETS:=$(LIQ_SERVER_BIN) $(CLI_BIN)

all: $(BUILD_TARGETS)

$(LIQ_SERVER_BIN): package.json $(LIQ_SERVER_FILES)
	JS_SRC=$(LIQ_SERVER_SRC) JS_OUT=$@ $(CATALYST_SCRIPTS) build

$(LIQ_SERVER_TEST_BUILT_FILES) &: $(LIQ_SERVER_TEST_SRC_FILES)
	JS_SRC=$(LIQ_SERVER_SRC) $(CATALYST_SCRIPTS) pretest

$(LIQ_SERVER_TEST_BUILT_DATA): test-staging/%: $(LIQ_SERVER_SRC)%
	mkdir -p $(dir $@)
	cp $< $@

test: $(LIQ_SERVER_TEST_BUILT_FILES) $(LIQ_SERVER_TEST_BUILT_DATA)
	JS_SRC=test-staging $(CATALYST_SCRIPTS) test

lint:
	JS_SRC=$(LIQ_SERVER_SRC) $(CATALYST_SCRIPTS) lint

lint-fix:
	JS_SRC=$(LIQ_SERVER_SRC) $(CATALYST_SCRIPTS) lint-fix

$(CLI_BIN): $(CLI_SRC_ROOT) $(CLI_SRC_FILES)
	mkdir -p $(dir $@)
	$(BASH_ROLLUP) $< $@

default: all

.PHONY: all test lint lint-fix
