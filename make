#!/bin/sh

build_frege() {
	test -e fregec.jar || make fetch-fregec.jar
	make fregec.jar
	zip -d fregec.jar '*.java'
	java -cp fregec.jar frege.compiler.Main -version | head -1 |
		sed -e 's/-\([0-9]\+\)-.*$/.\1/' > version
}

main() {
	set -e
	mkdir -p build
	cd build
	test -d frege || git clone https://github.com/Frege/frege.git
	( cd frege && build_frege )
	cd -
	sed 's/.*/version = '"'&'/" build/frege/version > frege-core/version.gradle
	cp build/frege/fregec.jar frege-core/
	./gradlew --no-daemon build
}

main "$@"
