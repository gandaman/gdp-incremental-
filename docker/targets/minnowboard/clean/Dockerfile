FROM gdpbuild/minnowboard_base

ENV REUSE_STANDARD_DL_DIR=false \
    REUSE_STANDARD_SSTATE_DIR=false \
    RM_WORK=true

WORKDIR /home/build/genivi-dev-platform
RUN bash -c "source ./init.sh $TARGET && bitbake genivi-dev-platform"
