# Containerfile to build g4music (Gapless / G4Music)
# https://gitlab.gnome.org/neithern/g4music

FROM fedora:latest AS builder

# Install build dependencies
RUN dnf install -y \
    vala meson gcc pkgconfig \
    gtk4-devel libadwaita-devel \
    gstreamer1-devel gstreamer1-plugins-base-devel \
    gettext-devel glib2-devel desktop-file-utils \
    && dnf clean all

WORKDIR /src
COPY . .

# Build with meson in a directory outside the copied source tree, so a host
# build/ directory (as created by the README instructions) is never reused.
RUN meson setup /tmp/g4music-build --buildtype=release \
    && meson compile -C /tmp/g4music-build \
    && meson install -C /tmp/g4music-build

# Runtime stage (optional)
FROM fedora:latest AS runtime
RUN dnf install -y \
    gtk4 libadwaita \
    gstreamer1 gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    glib2 \
    && dnf clean all
COPY --from=builder /usr/local /usr/local
ENTRYPOINT ["/usr/local/bin/g4music"]
