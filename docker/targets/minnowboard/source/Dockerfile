FROM gdpbuild/minnowboard_source_base

WORKDIR $PROJECTDIR
RUN git fetch origin && git checkout $REF
RUN bash -c "source ./init.sh $TARGET accept-eula && bitbake -c fetchall genivi-dev-platform"
