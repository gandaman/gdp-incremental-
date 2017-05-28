FROM gdpbuild/r-car-m3-yocto-kit_base

WORKDIR /home/build/genivi-dev-platform
RUN bash -c "source ./init.sh $TARGET && bitbake genivi-dev-platform"
CMD "/bin/bash"
