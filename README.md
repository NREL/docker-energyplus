# EnergyPlus Docker Container

This container has EnergyPlus 8.2 installed and can be used to run EnergyPlus on a single container.

## Example

To run EnergyPlus you should either mount your directory into the container or create a dependent container where you call `ADD . /var/simdata/energyplus`.

To mount the local folder and run EnergyPlus (on Linux only) make sure that your simulation directory is the current directory and run:

```
docker run -it --rm -v $(pwd):/var/simdata/energyplus nrel/energyplus:8.2 EnergyPlus
```
