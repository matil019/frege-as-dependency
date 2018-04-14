#!/bin/sh

build_frege() {
	make fetch-fregec.jar
	make clean fregec.jar
	zip -d fregec.jar '*.java'
}

main() {
	set -e
	mkdir build
	cd build
	git clone --depth=1 https://github.com/Frege/frege.git
	( cd frege && build_frege )
}

main "$@"
