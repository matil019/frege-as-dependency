#!/bin/sh

git_clone() {
	local url="$1"
	local name="${2-"$(basename "$1" .git)"}"
	if [ -d "$name" ]; then
		# assume the name of the remote is "origin"
		( cd "$name" && git fetch origin -p && git checkout -f master && git merge --ff-only origin/master )
	else
		# let's hope that 1000 is deep enough not to break git-describe
		git clone --depth=1000 "$url" "$name"
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
	./gradlew --no-daemon -p frege-core publishToMavenLocal

	cp frege-core/version.gradle frege-interpreter/
	./gradlew --no-daemon -p frege-interpreter install

	./gradlew --no-daemon -p frege-repl install

	mkdir -p frege-standalone/src/main/frege/frege/
	cp frege-core/frege/Starter.fr frege-standalone/src/main/frege/frege/
	cp frege-core/version.gradle frege-standalone/
	./gradlew --no-daemon -p frege-standalone assemble
}

main "$@"
