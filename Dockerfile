FROM ubuntu:14.04

MAINTAINER Nicholas Long nicholas.long@nrel.gov

# This is not ideal. The tarballs are not named nicely and EnergyPlus versioning is strange
ENV ENERGYPLUS_VERSION 8.2.0
ENV ENERGYPLUS_TAG v8.2.0-Update-1.2
ENV ENERGYPLUS_SHA 8397c2e30b

# This should be 8.2.0, but EnergyPlus convention is 8-2-0
ENV ENERGYPLUS_INSTALL_VERSION 8-2-0

# Downloading from Github
# https://github.com/NREL/EnergyPlus/releases/download/v8.2.0-Update-1.2/EnergyPlus-8.2.0-8397c2e30b-Linux-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_BASE_URL https://github.com/NREL/EnergyPlus/releases/download/$ENERGYPLUS_TAG
ENV ENERGYPLUS_DOWNLOAD_FILENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_URL $ENERGYPLUS_DOWNLOAD_BASE_URL/$ENERGYPLUS_DOWNLOAD_FILENAME

# Update packages
RUN apt-get update && apt-get install -y \
		ca-certificates curl \
		&& rm -rf /var/lib/apt/lists/*

# Collapse the download and installation into one command to make the container smaller &
# Remove a bunch of the auxiliary apps/files that are not needed in the container
RUN curl -SLO $ENERGYPLUS_DOWNLOAD_URL \
    && chmod +x $ENERGYPLUS_DOWNLOAD_FILENAME \
    && echo "y\r" | ./$ENERGYPLUS_DOWNLOAD_FILENAME \
		&& rm $ENERGYPLUS_DOWNLOAD_FILENAME \
		&& cd /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
    && rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
    PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater

# Remove the broken symlinks
RUN cd /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
		&& find -L . -type l -delete

RUN mkdir -p /var/simdata

CMD [ "/bin/bash" ]
