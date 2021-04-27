# EnergyPlus Docker Container

[![Build Status](https://travis-ci.org/NREL/docker-energyplus.svg?branch=main)](https://travis-ci.org/NREL/docker-energyplus)

This project has multiple versions of EnergyPlus ready for use in a single container.


## Docker Tags

Below is a table of the various docker tags and their meanings as seen on [this page](https://hub.docker.com/r/nrel/energyplus/tags/).

| Tag     | Description                                                                             |
|---------|-----------------------------------------------------------------------------------------|
| x.y.z   | Build of official EnergyPlus release (recommended use)                                  |
| latest  | Latest official release of EnergyPlus (e.g. 2.5.1)                                      |
| develop | Release of [develop branch](https://github.com/NREL/docker-energyplus/tree/develop)     |

## Building EnergyPlus Container

To build the EnergyPlus docker image locally, see the following example command for v9.3.0.

```
docker build --target base -t energyplus --build-arg ENERGYPLUS_VERSION=9.4.0 --build-arg ENERGYPLUS_TAG=v9.4.0 --build-arg ENERGYPLUS_SHA=998c4b761e --build-arg ENERGYPLUS_INSTALL_VERSION=9-4-0 .
```

## Example

To run EnergyPlus you should either mount your directory into the container or create a dependent container where you call `ADD . /var/simdata/energyplus`.

To mount the local folder and run EnergyPlus (on Linux only) make sure that your simulation directory is the current directory and run:

```
docker run -it --rm -v $(pwd):/var/simdata/energyplus nrel/energyplus /bin/bash -c "cp /usr/local/bin/Energy+.idd /var/simdata/energyplus; cd /var/simdata/energyplus && EnergyPlus"
```
