.POSIX:

ROOTDIR  = $$PWD

all:
	@if [ ! -d build ]; then \
		mkdir build;     \
	fi
	@cd build; voc -s ${ROOTDIR}/../src/optsos.Mod    \
		       -s ${ROOTDIR}/../src/opts.Mod      \
		          ${ROOTDIR}/../src/testopts.Mod -m

clean:
	rm -rf build
