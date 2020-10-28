VOC = /opt/voc/bin/voc
BLD = build


all:
		git submodule init
		git submodule update
		mkdir -p $(BLD)
		cd $(BLD) && $(VOC) -s ../src/optsos.Mod \
		../src/opts.Mod \
		../src/testopts.Mod -m
