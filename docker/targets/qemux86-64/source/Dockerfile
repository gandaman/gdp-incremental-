FROM gdpbuild/qemux86-64_base

WORKDIR $PROJECTDIR
RUN bash -c "source ./init.sh $TARGET accept-eula && bitbake -c fetchall genivi-dev-platform"

