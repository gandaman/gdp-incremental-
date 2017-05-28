FROM gdpbuild/r-car-m3-starter-kit_base

ENV REUSE_STANDARD_DL_DIR=false \
    REUSE_STANDARD_SSTATE_DIR=false \
    RM_WORK=true

WORKDIR /home/build/genivi-dev-platform
RUN bash -c "source ./init.sh $TARGET"
WORKDIR gdp-src-build
RUN bitbake -c fetchall genivi-dev-platform

CMD scripts/ci-build.sh CI_FLAG
