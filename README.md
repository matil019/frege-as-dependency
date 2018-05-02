# Frege as Maven Dependency

This project consists of scripts that clones [frege][1](called `frege-core` in
this project), [frege-interpreter][2], and [frege-repl][3], builds them with the
same version of Frege, and packages them into individual maven artifacts. This
project aims to make Frege easier for JVM projects to use it as their
dependencies.

As a bonus, this also produces a standalone distribution of Frege, which is
comparable to [the official releases][4].

[1]: https://github.com/Frege/frege
[2]: https://github.com/Frege/frege-interpreter
[3]: https://github.com/Frege/frege-repl
[4]: https://github.com/Frege/frege/releases/tag/3.24public


## Requirements

### Common requirements for running Frege

- JDK8 or later

### Common requirements for building Frege

- git

### Building frege-core

- JDK9
  - JDK8 does *not* work
  - If you wish to build all subprojects at once (as in the case if you run
    `./make`), Oracle's Java SE 9 is recommended
- make
- byacc (Berkeley Yacc)
- time command (Not the shell builtin)
- zip

### Building frege-interpreter

- JDK8 or 9

### Building frege-repl

- JDK8 or 9 with OpenJFX support
  - Note that if you would like to use OpenJDK9, you have to build OpenJDK with
    OpenJFX support enabled. For details, see the [documentation][5]

[5]: https://wiki.openjdk.java.net/display/OpenJFX/Building+OpenJFX#BuildingOpenJFX-IntegrationwithOpenJDK

### Or, use Docker

You can use `archlinux/docker/Dockerfile` to build a Docker image which is used
to run the `./make` script.

Build and run it like:

```
$ docker build --network host -t local/frege-as-dependency archlinux/docker/
$ docker run --rm -it -u "$(id -u):$(id -g)" -w "$PWD" -v "$PWD:$PWD" \
             local/frege-as-dependency ./make
```

Even if you don't use Docker, you can still read the Dockerfile to have a
concrete idea of the build requirements.


## Building

For all-in build, run the `./make` script. It clones Frege projects, patches
gradle configurations, and builds them. Please note that the script installs
Frege artifacts into your local repository along the way.
