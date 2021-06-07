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
ENV ENERGYPLUS_DOWNLOAD_BASENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-Ubuntu18.04-x86_64
ENV ENERGYPLUS_DOWNLOAD_FILENAME $ENERGYPLUS_DOWNLOAD_BASENAME.tar.gz
ENV ENERGYPLUS_DOWNLOAD_URL $ENERGYPLUS_DOWNLOAD_BASE_URL/$ENERGYPLUS_DOWNLOAD_FILENAME

# Collapse the update of packages, download and installation into one command
# to make the container smaller & remove a bunch of the auxiliary apps/files
# that are not needed in the container
RUN apt-get update && apt-get install -y ca-certificates curl libx11-6 libexpat1\
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO $ENERGYPLUS_DOWNLOAD_URL \
    && tar -zxvf $ENERGYPLUS_DOWNLOAD_FILENAME \
    && rm $ENERGYPLUS_DOWNLOAD_FILENAME \
    && cd $ENERGYPLUS_DOWNLOAD_BASENAME \
    && ln -s energyplus EnergyPlus \
    && mkdir -p /var/simdata/energyplus \
    && cp ExampleFiles/1ZoneUncontrolled.idf /var/simdata \
    && cp ExampleFiles/PythonPluginCustomOutputVariable.idf /var/simdata \
    && cp ExampleFiles/PythonPluginCustomOutputVariable.py /var/simdata \
    && rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
    PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater

ENV PATH="/${ENERGYPLUS_DOWNLOAD_BASENAME}:${PATH}"

CMD [ "/bin/bash" ]
