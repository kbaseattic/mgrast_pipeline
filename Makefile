TOP_DIR = ../..
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
include $(TOP_DIR)/tools/Makefile.common

SERVICE_NAME = mgrast_pipeline
SERVICE_DIR  = mgrast_pipeline


TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE_NAME) --define kb_service_dir=$(SERVICE_DIR)


SCRIPTS_TESTS = $(wildcard script-tests/*.t)





default:
	-rm -rf pipeline/*
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

# over ride SRC_PERL. We can't do this until the default target
# has run the git submodule update. 
deploy: SRC_PERL = $(wildcard(pipeline/awecmd/*)

deploy: deploy-scripts deploy-docs
	echo "deploy target not implemented yet"


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
	echo "build-docs not implemented yet"


compile-docs:
	echo "compile-docs not implemented yet"


include $(TOP_DIR)/tools/Makefile.common.rules
