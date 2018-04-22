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
	git_clone https://github.com/Frege/frege-repl.git
}

build_frege() {
	test -e fregec.jar || make fetch-fregec.jar
	make fregec.jar
	zip -d fregec.jar '*.java'
	java -cp fregec.jar frege.compiler.Main -version | head -1 |
		sed -e 's/-\([0-9]\+\)-.*$/.\1/' |
		sed -e 's/.*/version = '"'&'/" > version.gradle
}

main() {
	set -e
	prepare
	( cd frege-core && build_frege )
	./gradlew --no-daemon build
}

main "$@"
