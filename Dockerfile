FROM ubuntu:14.04

MAINTAINER Nicholas Long nicholas.long@nrel.gov

# This is not ideal. The tarballs are not named nicely and EnergyPlus versioning is strange
ENV ENERGYPLUS_VERSION 810009

# This should be 8.1.0, but EnergyPlus convention is 8-1-0
ENV ENERGYPLUS_INSTALL_VERSION 8-1-0

# Update packages
RUN apt-get update && apt-get install -y \
		ca-certificates curl \
		&& rm -rf /var/lib/apt/lists/*

# Collapse the download and installation into one command to make the container smaller &
# Remove a bunch of the auxiliary apps/files that are not needed in the container
RUN curl -SLO "http://developer.nrel.gov/downloads/buildings/energyplus/builds/SetEPlusV$ENERGYPLUS_VERSION-lin-64.tar.gz" \
    && mkdir /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
    && tar xzf "SetEPlusV$ENERGYPLUS_VERSION-lin-64.tar.gz" -C /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
    && rm "SetEPlusV$ENERGYPLUS_VERSION-lin-64.tar.gz" \
		&& cd /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION \
    && rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
    PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater

RUN cd /usr/local/bin \
    && find /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/EnergyPlus -type f -perm -o+rx -exec ln -s {} \; \
    && find /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/ExpandObjects -type f -perm -o+rx -exec ln -s {} \; \
    && find /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/EPMacro -type f -perm -o+rx -exec ln -s {} \; \
    && find /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/runenergyplus -type f -perm -o+rx -exec ln -s {} \; \
    && find /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/runepmacro -type f -perm -o+rx -exec ln -s {} \; \
    && find /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION/runreadvars -type f -perm -o+rx -exec ln -s {} \;

RUN mkdir -p /var/simdata

CMD [ "/bin/bash" ]
