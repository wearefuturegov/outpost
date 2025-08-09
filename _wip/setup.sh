# This script is used to set up the Outpost DEVELOPMENT (and test) environment.
# It is based on the Heroku base images, which we're unable to use yet because of architecture issues 
# https://github.com/heroku/base-images

#!/usr/bin/env bash

echo -e "\033[1m==============================\033[0m"
echo -e "       \033[1;32mSTARTING SETUP\033[0m  "
echo -e "\033[1m==============================\033[0m"

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive


echo
echo -e "\033[34m----- Setting correct sources for architecture -----\033[0m"
echo

# Set the correct Ubuntu sources mirror for the current architecture
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
  cat >/etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ jammy main universe
deb http://archive.ubuntu.com/ubuntu/ jammy-security main universe
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main universe
EOF
else
  cat >/etc/apt/sources.list <<EOF
deb http://ports.ubuntu.com/ubuntu-ports/ jammy main universe
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-security main universe
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main universe
EOF
fi

apt-get update --error-on=any

# Required by apt-key and does not exist in the base image on newer Ubuntu.
apt-get install -y --no-install-recommends gnupg



echo
echo -e "\033[34mUpgrading postgres client\033[0m"
echo

# In order to support all features offered by Heroku Postgres, we need newer postgresql-client
# than is available in the Ubuntu repository, so use the upstream APT repository instead:
# https://wiki.postgresql.org/wiki/Apt
cat >>/etc/apt/sources.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main
EOF
apt-key add /build/postgresql-ACCC4CF8.asc

apt-get update --error-on=any
apt-get upgrade -y


echo
echo -e "\033[34m----- INSTALL BASE PACKAGES -----\033[0m"
echo


packages=(
  apt-transport-https
  apt-utils
  bind9-host
  bzip2
  ca-certificates
  coreutils
  curl
  dnsutils
  ed
  file
  fontconfig
  gcc
  geoip-database
  gettext-base
  ghostscript
  gir1.2-harfbuzz-0.0
  git
  gsfonts
  imagemagick
  iproute2
  iputils-tracepath
  jq # Used by Heroku Exec at run time, and buildpacks at build time.
  language-pack-en
  less
  libaom3
  libargon2-1
  libass9
  libc-ares2 # Used by PgBouncer in heroku-buildpack-pgbouncer.
  libc-client2007e
  libc6-dev
  libcairo2
  libcurl4
  libdatrie1
  libdav1d5
  libev4
  libevent-2.1-7
  libevent-core-2.1-7
  libevent-extra-2.1-7
  libevent-openssl-2.1-7
  libevent-pthreads-2.1-7
  libexif12
  libfreetype6
  libfribidi0
  libgd3
  libgdk-pixbuf2.0-0
  libgdk-pixbuf2.0-common
  libgnutls-openssl27
  libgnutls30
  libgnutlsxx28
  libgraphite2-3
  libgraphite2-3
  libgs9
  libharfbuzz-gobject0
  libharfbuzz-icu0
  libharfbuzz0b
  libhashkit2
  libheif1
  liblttng-ust1
  liblzf1
  libmagickcore-6.q16-3-extra
  libmcrypt4
  libmemcached11
  libmemcachedutil2
  libmp3lame0
  libmysqlclient21
  libnetpbm10
  libnuma1
  libogg0
  libonig5
  libopencore-amrnb0
  libopencore-amrwb0
  libopus0
  libpango-1.0-0
  libpangocairo-1.0-0
  libpangoft2-1.0-0
  libpixman-1-0
  librabbitmq4
  librsvg2-2
  librsvg2-common
  libsasl2-modules
  libseccomp2
  libsodium23
  libspeex1
  libsvtav1enc0
  libthai-data
  libthai0
  libtheora0
  libunistring2
  libuv1
  libvips42
  libvorbis0a
  libvorbisenc2
  libvorbisfile3
  libvpx7
  libwebp7
  libwebpdemux2
  libwebpmux3
  libwmf-0.2-7
  libx264-163
  libx265-199
  libxcb-render0
  libxcb-shm0
  libxrender1
  libxslt1.1
  libyaml-0-2
  libzip4
  libzstd1
  locales
  lsb-release
  make
  nano # More usable than ed but still much smaller than vim.
  netcat-openbsd
  openssh-client
  openssh-server
  patch
  poppler-utils
  postgresql-client-17
  python-is-python3
  python3
  rename
  rsync
  shared-mime-info
  socat
  stunnel
  # syslinux # Not needed in the container, and causes issues with the build.
  tar
  telnet
  tzdata
  unzip
  wget
  xz-utils
  zip
  zlib1g
  zstd
)

apt-get install -y --no-install-recommends "${packages[@]}"



echo
echo -e "\033[34m----- INSTALL BUILD PACKAGES -----\033[0m"
echo



packages=(
  autoconf
  automake
  bison
  build-essential
  # bzr # not needed
  cmake
  gettext
  git
  libacl1-dev
  libapt-pkg-dev
  libargon2-dev
  libattr1-dev
  libaudit-dev
  libbsd-dev
  libbz2-dev
  libc-client2007e-dev
  libcairo2-dev
  libcap-dev
  libcurl4-openssl-dev
  libdb-dev
  libev-dev
  libevent-dev
  libexif-dev
  libffi-dev
  libgcrypt20-dev
  libgd-dev
  libgdbm-dev
  libgeoip-dev
  libglib2.0-dev
  libgnutls28-dev
  libgs-dev
  libheif-dev
  libicu-dev
  libidn11-dev
  libjpeg-dev
  libkeyutils-dev
  libkmod-dev
  libkrb5-dev
  libldap2-dev
  liblz4-dev
  liblzf-dev
  libmagic-dev
  libmagickwand-dev
  libmcrypt-dev
  libmemcached-dev
  libmysqlclient-dev
  libncurses5-dev
  libncursesw5-dev
  libnetpbm10-dev
  libonig-dev
  libpam0g-dev
  libpopt-dev
  libpq-dev
  librabbitmq-dev
  libreadline-dev
  librtmp-dev
  libseccomp-dev
  libselinux1-dev
  libsemanage-dev
  libsodium-dev
  libssl-dev
  libsystemd-dev
  libtool
  libudev-dev
  libuv1-dev
  libwrap0-dev
  libxml2-dev
  libxslt-dev
  libyaml-dev
  libzip-dev
  libzstd-dev
  #mercurial # not needed
  patchelf
  python3-dev
  zlib1g-dev
)

apt-get update --error-on=any
apt-get install -y --no-install-recommends "${packages[@]}"

echo
echo -e "\033[34m----- CLEANUP -----\033[0m"
echo

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*


export DEBIAN_FRONTEND=

