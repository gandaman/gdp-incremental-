FROM gdpbuild/r-car-m3-starter-kit_base

WORKDIR $PROJECTDIR
RUN bash -c "source ./init.sh $TARGET accept-eula && bitbake -c fetchall genivi-dev-platform"
