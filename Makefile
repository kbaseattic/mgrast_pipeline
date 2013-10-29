TOP_DIR = ../..
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
include $(TOP_DIR)/tools/Makefile.common

SERVICE_NAME =
SERVICE_DIR  =


TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE_NAME) --define kb_service_dir=$(SERVICE_DIR)


CLIENT_TESTS = $(wildcard client-tests/*.t)
SCRIPTS_TESTS = $(wildcard script-tests/*.t)
SERVER_TESTS = $(wildcard server-tests/*.t)

default:
	-rm -r pipeline/*
	git submodule init
	git submodule update




# Test Section

test: test-scripts
	@echo "running client and script tests"



test-scripts:
	# run each test
	for t in $(SCRIPT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done



deploy: deploy-client


deploy-client: deploy-scripts deploy-docs


deploy-scripts: deploy-cfg
	export KB_TOP=$(TARGET); \
	export KB_RUNTIME=$(DEPLOY_RUNTIME); \
	export KB_PERL_PATH=$(TARGET)/lib bash ; \
	for src in $(SRC_PERL) ; do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $$src $$base ; \
		cp $$src $(TARGET)/plbin ; \
		$(WRAP_PERL_SCRIPT) "$(TARGET)/plbin/$$basefile" $(TARGET)/bin/$$base ; \
	done



deploy-docs: build-docs
	-mkdir -p $(TARGET)/services/$(SERVICE_DIR)/webroot/.
	cp docs/*.html $(TARGET)/services/$(SERVICE_DIR)/webroot/.


build-docs: compile-docs
	-mkdir -p docs
	pod2html --infile=lib/Bio/KBase/$(SERVICE_NAME)/Client.pm --outfile=docs/$(SERVICE_NAME).html



compile-docs:


include $(TOP_DIR)/tools/Makefile.common.rules
