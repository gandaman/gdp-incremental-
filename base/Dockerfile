# Building on top of https://github.com/gmacario/easy-build
FROM gmacario/build-yocto

USER build
WORKDIR /home/build
RUN git clone https://github.com/GENIVI/genivi-dev-platform
RUN chown -R build:build /home/build
ENV LC_ALL=en_US.UTF-8
CMD "/bin/bash"
