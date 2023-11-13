VOC = /opt/voc/bin/voc
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD = build
build_dir_path := $(mkfile_dir_path)/$(BUILD)
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
BLD := $(mkfile_dir_path)/build
DPD  =  deps
DPS := $(mkfile_dir_path)/$(DPD)

all: get_deps build_deps build

get_deps:
		mkdir -p $(DPS)
		if [ -d $(DPS)/lists ]; then cd $(DPS)/lists; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/lists; cd -; fi

build_deps:
		mkdir -p $(BUILD)
		cd $(BUILD) && make -f $(mkfile_dir_path)/$(DPD)/lists/GNUmakefile BUILD=$(BLD)

build:
		cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/optsos.Mod
		cd $(BUILD) && $(VOC) -s $(mkfile_dir_path)/src/opts.Mod

tests:
		cd $(BUILD) && $(VOC) $(mkfile_dir_path)/test/testopts.Mod -m
		build/testopts

clean:
	if [ -d "$(BUILD)" ]; then rm -rf $(BLD); fi

