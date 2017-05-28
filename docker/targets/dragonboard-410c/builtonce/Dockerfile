FROM gdpbuild/dragonboard-410c_source

ENV REUSE_STANDARD_DL_DIR=false \
    REUSE_STANDARD_SSTATE_DIR=false \
    RM_WORK=true

RUN bash -c "source ./init.sh $TARGET accept-eula && bitbake genivi-dev-platform"
