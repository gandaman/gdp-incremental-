FROM gdpbuild/dragonboard_base

WORKDIR $PROJECTDIR
RUN bash -c "source ./init.sh $TARGET"
WORKDIR gdp-src-build
RUN bitbake -c fetchall genivi-dev-platform

