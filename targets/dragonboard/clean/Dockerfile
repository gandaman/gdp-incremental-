FROM gdpbuild/dragonboard_base

WORKDIR /home/build/genivi-dev-platform
RUN bash -c "source ./init.sh $TARGET && bitbake genivi-dev-platform"
CMD "/bin/bash"
