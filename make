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
	mkdir -p upstream
	cd upstream
	test -d frege || git clone https://github.com/Frege/frege.git
	( cd frege && build_frege )
	cd -
	sed 's/.*/version = '"'&'/" upstream/frege/version > frege-core/version.gradle
	cp upstream/frege/fregec.jar frege-core/
	./gradlew --no-daemon build
}

main "$@"
