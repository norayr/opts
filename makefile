VOC = /opt/voc/bin/voc
BUILD = build
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

all:
		#git submodule init
		#git submodule update
		mkdir -p $(BUILD)
		cd $(BUILD) && $(VOC) -s  $(mkfile_dir_path)/src/src/optsos.Mod \
		$(mkfile_dir_path)/src/src/opts.Mod \
		$(mkfile_dir_path)/src/testopts.Mod -m
