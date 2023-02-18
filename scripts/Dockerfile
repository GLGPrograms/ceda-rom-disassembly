FROM ubuntu:22.04

RUN apt update && apt upgrade -y && apt install -y build-essential bison flex libxml2-dev subversion zlib1g-dev m4 ragel re2c dos2unix texinfo texi2html gdb curl perl cpanminus ccache libboost-all-dev libmodern-perl-perl libyaml-perl liblocal-lib-perl libcapture-tiny-perl libpath-tiny-perl libtext-table-perl libdata-hexdump-perl libregexp-common-perl libclone-perl libfile-slurp-perl make git

ENV PATH="$PATH:/opt/z88dk/bin"
ENV ZCCCFG="/opt/z88dk/lib/config"
WORKDIR /opt
RUN git clone --recursive https://github.com/z88dk/z88dk.git && cd /opt/z88dk && ./build.sh

