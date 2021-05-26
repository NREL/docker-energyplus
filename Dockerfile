FROM ubuntu:18.04 AS base

MAINTAINER Nicholas Long nicholas.long@nrel.gov

# This is not ideal. The tarballs are not named nicely and EnergyPlus versioning is strange
ARG ENERGYPLUS_VERSION
ARG ENERGYPLUS_TAG
ARG ENERGYPLUS_SHA
ARG ENERGYPLUS_INSTALL_VERSION
ENV ENERGYPLUS_VERSION=$ENERGYPLUS_VERSION
ENV ENERGYPLUS_TAG=v$ENERGYPLUS_VERSION
ENV ENERGYPLUS_SHA=$ENERGYPLUS_SHA

# This should be x.y.z, but EnergyPlus convention is x-y-z
ENV ENERGYPLUS_INSTALL_VERSION=$ENERGYPLUS_INSTALL_VERSION

# Downloading from Github
# e.g. https://github.com/NREL/EnergyPlus/releases/download/v8.3.0/EnergyPlus-8.3.0-6d97d074ea-Linux-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_BASE_URL https://github.com/NREL/EnergyPlus/releases/download/$ENERGYPLUS_TAG
ENV ENERGYPLUS_DOWNLOAD_FILENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-Ubuntu18.04-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_URL $ENERGYPLUS_DOWNLOAD_BASE_URL/$ENERGYPLUS_DOWNLOAD_FILENAME

# Download
RUN apt-get update && apt-get install -y ca-certificates curl libx11-6 libexpat1\
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO $ENERGYPLUS_DOWNLOAD_URL

# Install
RUN chmod +x $ENERGYPLUS_DOWNLOAD_FILENAME \
    && echo "y\r" | ./$ENERGYPLUS_DOWNLOAD_FILENAME \
    && rm $ENERGYPLUS_DOWNLOAD_FILENAME \
    && cd /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
    && rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
    PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater

# Remove the broken symlinks
RUN cd /usr/local/bin \
    && find -L . -type l -delete

# Add in the test files
ADD test /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/test_run
RUN cp /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/Energy+.idd \
        /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/test_run/

# Use Multi-stage build to produce a smaller final image
FROM ubuntu:18.04 AS runtime

ARG ENERGYPLUS_INSTALL_VERSION
ENV ENERGYPLUS_INSTALL_VERSION=$ENERGYPLUS_INSTALL_VERSION

COPY --from=base /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/ \
        /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/
COPY --from=base /usr/local/bin /usr/local/bin
COPY --from=base /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=base /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/

VOLUME /var/simdata/energyplus
WORKDIR /var/simdata/energyplus

CMD [ "/bin/bash" ]
