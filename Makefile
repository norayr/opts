.POSIX:

all:
	@if [ ! -d build ]; then \
		mkdir build;     \
	fi
	@cd build; voc -s ${.CURDIR}/src/optsos.Mod    \
		      -s ${.CURDIR}/src/opts.Mod      \
		         ${.CURDIR}/src/testopts.Mod -m

clean:
	rm -rf build
