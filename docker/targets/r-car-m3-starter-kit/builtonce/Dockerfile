FROM gdpbuild/r-car-m3-yocto-kit_source

ENV REUSE_STANDARD_DL_DIR=false \
    REUSE_STANDARD_SSTATE_DIR=false \
    RM_WORK=true

RUN bash -c "source ./init.sh $TARGET && bitbake genivi-dev-platform"
