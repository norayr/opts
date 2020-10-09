VOC = /opt/voc/bin/voc
BLD = build


all:
		mkdir -p $(BLD)
		cd $(BLD) && $(VOC) -s ../src/getopt.Mod
