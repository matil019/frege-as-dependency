#!/bin/sh

git_clone() {
	local url="$1"
	local name="${2-"$(basename "$1" .git)"}"
	if [ -d "$name" ]; then
		# assume the name of the remote is "origin"
		( cd "$name" && git fetch origin -p && git checkout -f master && git merge --ff-only origin/master )
	else
		git clone "$url" "$name"
	fi
}

prepare() {
	git_clone https://github.com/Frege/frege.git frege-core
	cp patches/frege-core-build.gradle frege-core/build.gradle
	git_clone https://github.com/Frege/frege-interpreter.git
	( cd frege-interpreter && patch -Np1 -i ../patches/frege-interpreter.patch )
	git_clone https://github.com/Frege/frege-repl.git
	( cd frege-repl && patch -Np1 -i ../patches/frege-repl.patch )
}

build_frege() {
	test -e fregec.jar || make fetch-fregec.jar
	make fregec.jar
	zip -d fregec.jar '*.java'
	java -cp fregec.jar frege.compiler.Main -version | head -1 |
		sed -e 's/-\([0-9]\+\)-.*$/.\1/' |
		sed -e 's/.*/ext { fregeVersion = '"'&' }/" > version.gradle
}

main() {
	set -e
	prepare

	( cd frege-core && build_frege )
	./gradlew -p frege-core publishToMavenLocal

	# Needs Java8, Java9 doesn't work
	cp frege-core/version.gradle frege-interpreter/
	./gradlew -p frege-interpreter install

	./gradlew -p frege-repl install

	mkdir -p frege-standalone/src/main/frege/frege/
	cp frege-core/frege/Starter.fr frege-standalone/src/main/frege/frege/
	cp frege-core/version.gradle frege-standalone/
	./gradlew -p frege-standalone install
}

main "$@"
