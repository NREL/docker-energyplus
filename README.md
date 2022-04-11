# EnergyPlus Docker Container

![Build Status](https://github.com/nrel/docker-energyplus/actions/workflows/publish.yml/badge.svg?branch=main)


This project has multiple versions of EnergyPlus ready for use in a single container.


## Docker Tags

Below is a table of the various docker tags and their meanings as seen on [this page](https://hub.docker.com/r/nrel/energyplus/tags/).

| Tag     | Description                                                                         |
|---------|-------------------------------------------------------------------------------------|
| x.y.z   | Build of official EnergyPlus release (recommended use)                              |
| latest  | Latest official release of EnergyPlus (e.g. 22.1.0)                                 |
| develop | Release of [develop branch](https://github.com/NREL/docker-energyplus/tree/develop) |

## Building EnergyPlus Container

To build the EnergyPlus docker image locally, see the following example command for v22.1.0 using Ubuntu 20.04 as the base image.

```
docker build -t energyplus --build-arg ENERGYPLUS_VERSION=22.1.0 --build-arg ENERGYPLUS_SHA=ed759b17ee --build-arg ENERGYPLUS_INSTALL_VERSION=22-1-0 --build-arg ENERGYPLUS_TAG=v22.1.0 --build-arg UBUNTU_BASE=20.04 .
```

## Example

To run EnergyPlus you should either mount your directory into the container or create a dependent container where you call `ADD . /var/simdata/energyplus`.

To mount the local folder and run EnergyPlus (on Linux only) make sure that your simulation directory is the current directory and run:

```
docker run -it --rm -v $(pwd):/var/simdata/energyplus nrel/energyplus /bin/bash -c "cp /usr/local/bin/Energy+.idd /var/simdata/energyplus; cd /var/simdata/energyplus && EnergyPlus"
```
