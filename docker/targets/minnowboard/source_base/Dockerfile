FROM gdpbuild/minnowboard_base

WORKDIR $PROJECTDIR
RUN git fetch origin && git checkout origin/master
RUN bash -c "source ./init.sh $TARGET accept-eula && bitbake -c fetchall genivi-dev-platform"
