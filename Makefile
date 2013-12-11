TOP_DIR = ../..
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
include $(TOP_DIR)/tools/Makefile.common

SERVICE_NAME = mgrast_pipeline
SERVICE_DIR  = mgrast_pipeline

TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE_NAME) --define kb_service_dir=$(SERVICE_DIR)

SCRIPTS_TESTS = $(wildcard script-tests/*.t)

default:
	-rm -rf pipeline
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

# over ride SRC_PERL for deploy and all sub targets
deploy-scripts: SRC_PERL = $(wildcard pipeline/awecmd/*.pl)   \
                   		   $(wildcard pipeline/bin/*.pl)
deploy-scripts: SRC_PYTHON = $(wildcard pipeline/awecmd/*.py) \
                     		 $(wildcard pipeline/bin/*.py)
deploy-scripts: SRC_SH = $(wildcard pipeline/awecmd/*.sh)     \
                 		 $(wildcard pipeline/bin/*.sh)
deploy-scripts: SRC_UNKNOWN = $(filter-out %.sh %.py %.pl, $(wildcard pipeline/bin/*))

deploy-client: build-libs deploy-libs | deploy-scripts

build-libs:
	-mkdir -p lib
	-cp pipeline/lib/*.pm lib
	-cp pipeline/conf/*.pm lib

deploy: deploy-client deploy-docs deploy-cfg
	echo "deploy target not implemented yet"

deploy-docs: build-docs
	-mkdir -p $(TARGET)/services/$(SERVICE_DIR)/webroot/.
	cp docs/*.html $(TARGET)/services/$(SERVICE_DIR)/webroot/.

build-docs:
	-mkdir -p docs
	echo "build-docs not implemented yet" > docs/$(SERVICE_NAME).html

# for updating and deploying submodule
build-update:
	cd pipeline; git pull origin master

update: default build-update deploy-client |

include $(TOP_DIR)/tools/Makefile.common.rules
