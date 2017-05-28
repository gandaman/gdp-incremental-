# Building on top of https://github.com/gmacario/easy-build
FROM gmacario/build-yocto

USER build
ENV USER build
ENV HOMEDIR=/home/$USER

ENV REPO_URL=https://github.com/GENIVI/genivi-dev-platform
ENV PROJECTDIR=$HOMEDIR/genivi-dev-platform

WORKDIR $HOMEDIR
RUN git clone $REPO_URL

RUN chown -R $USER:$USER $HOMEDIR
ENV LC_ALL=en_US.UTF-8

# Clone and update most submodules once and for all here in the base image.
# Using qemux86-64 target because it does not bring in any particular BSPs
WORKDIR $PROJECTDIR
RUN bash -c "source ./init.sh qemux86-64"

CMD "/bin/bash"
