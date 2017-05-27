# Building on top of https://github.com/gmacario/easy-build

FROM gdpbuild/minnowboard_base

WORKDIR /home/build/genivi-dev-platform

# Starting with an arbitrary hash for now
RUN git fetch 

USER build

ADD build.sh build.sh

ENV TARGET=minnowboard \
    REUSE_STANDARD_DL_DIR=false \
    REUSE_STANDARD_SSTATE_DIR=false \
    RM_WORK=true

CMD scripts/ci-build.sh CI_FLAG

