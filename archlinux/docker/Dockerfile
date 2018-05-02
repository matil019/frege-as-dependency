FROM base/devel as build

RUN pacman -Syu --noconfirm git
RUN git clone --depth=1 https://aur.archlinux.org/jdk9.git
RUN cd jdk9 && \
    bash -c '. PKGBUILD && pacman -Syu --noconfirm && pacman -S --asdeps --needed --noconfirm "${makedepends[@]}" "${depends[@]}"' && \
    chown -R nobody . && \
    su -s /bin/bash nobody makepkg && \
    cp jdk9*.pkg.tar.xz /jdk9.pkg.tar.xz


FROM base/archlinux

RUN pacman -Syu --noconfirm make byacc git time zip patch && \
    pacman -Scc --noconfirm

COPY --from=build /jdk9.pkg.tar.xz /
RUN pacman -U --noconfirm /jdk9.pkg.tar.xz
