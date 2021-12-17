# Keep ARG outside of build images so can access globally
# This is not ideal. The tarballs are not named nicely and EnergyPlus versioning is strange
ARG ENERGYPLUS_VERSION
ARG ENERGYPLUS_SHA
ARG ENERGYPLUS_INSTALL_VERSION
ARG ENERGYPLUS_TAG

FROM ubuntu:18.04 AS base

MAINTAINER Nicholas Long nicholas.long@nrel.gov

ARG ENERGYPLUS_VERSION
ARG ENERGYPLUS_SHA
ARG ENERGYPLUS_INSTALL_VERSION
ARG ENERGYPLUS_TAG
ENV ENERGYPLUS_VERSION=$ENERGYPLUS_VERSION
ENV ENERGYPLUS_TAG=$ENERGYPLUS_TAG
ENV ENERGYPLUS_SHA=$ENERGYPLUS_SHA

# This should be x.y.z, but EnergyPlus convention is x-y-z
ENV ENERGYPLUS_INSTALL_VERSION=$ENERGYPLUS_INSTALL_VERSION

# Downloading from Github
# e.g. https://github.com/NREL/EnergyPlus/releases/download/v8.3.0/EnergyPlus-8.3.0-6d97d074ea-Linux-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_BASE_URL https://github.com/NREL/EnergyPlus/releases/download/$ENERGYPLUS_TAG
ENV ENERGYPLUS_DOWNLOAD_BASENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-Ubuntu18.04-x86_64
ENV ENERGYPLUS_DOWNLOAD_FILENAME $ENERGYPLUS_DOWNLOAD_BASENAME.tar.gz
ENV ENERGYPLUS_DOWNLOAD_URL $ENERGYPLUS_DOWNLOAD_BASE_URL/$ENERGYPLUS_DOWNLOAD_FILENAME

ENV SIMDATA_DIR=/var/simdata

# Download
RUN apt-get update \
    && apt-get install -y ca-certificates curl libx11-6 libexpat1 python3 python3-pip \
    && curl -SLO $ENERGYPLUS_DOWNLOAD_URL

# Unzip
RUN tar -zxvf $ENERGYPLUS_DOWNLOAD_FILENAME \
    && cd $ENERGYPLUS_DOWNLOAD_BASENAME \
    && chmod +x energyplus \
    && ln -s energyplus EnergyPlus

RUN mkdir -p  $SIMDATA_DIR/energyplus \
    && cd $ENERGYPLUS_DOWNLOAD_BASENAME \
    && cp ExampleFiles/1ZoneUncontrolled.idf $SIMDATA_DIR \
    && cp ExampleFiles/PythonPluginCustomOutputVariable.idf $SIMDATA_DIR \
    && cp ExampleFiles/PythonPluginCustomOutputVariable.py $SIMDATA_DIR

# Remove datasets to slim down the EnergyPlus folder
RUN rm ${ENERGYPLUS_DOWNLOAD_BASENAME}.tar.gz \
    && cd $ENERGYPLUS_DOWNLOAD_BASENAME \
    && rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
    PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater

# Add energyplus to PATH so can run "energyplus" in any directory
ENV PATH="/${ENERGYPLUS_DOWNLOAD_BASENAME}:${PATH}"
CMD [ "/bin/bash" ]

# Use Multi-stage build to produce a smaller final image
FROM ubuntu:18.04 AS runtime

ARG ENERGYPLUS_VERSION
ARG ENERGYPLUS_SHA
ENV ENERGYPLUS_VERSION=$ENERGYPLUS_VERSION
ENV ENERGYPLUS_SHA=$ENERGYPLUS_SHA
ENV ENERGYPLUS_DOWNLOAD_BASENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-Ubuntu18.04-x86_64
ENV SIMDATA_DIR=/var/simdata

COPY --from=base $ENERGYPLUS_DOWNLOAD_BASENAME $ENERGYPLUS_DOWNLOAD_BASENAME
COPY --from=base $SIMDATA_DIR $SIMDATA_DIR

# Copy shared libraries required to run energyplus
COPY --from=base \
    /usr/lib/x86_64-linux-gnu/libX11.so.1* \
    /usr/lib/x86_64-linux-gnu/libX11.so.6* \
    /usr/lib/x86_64-linux-gnu/libxcb.so.1* \
    /usr/lib/x86_64-linux-gnu/libXau.so.6* \
    /usr/lib/x86_64-linux-gnu/libXau.so.6* \
    /usr/lib/x86_64-linux-gnu/libXdmcp.so.6* \
    /usr/lib/x86_64-linux-gnu/
COPY --from=base \
    /lib/x86_64-linux-gnu/libbsd.so.0* \
    /lib/x86_64-linux-gnu/libexpat.so.1* \
    /lib/x86_64-linux-gnu/
