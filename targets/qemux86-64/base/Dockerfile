FROM gdpbuild/base

# Updating submodules
ENV TARGET=qemu-x86_64
WORKDIR /home/build/genivi-dev-platform
RUN bash -c "source ./init.sh $TARGET"

CMD "/bin/bash"
