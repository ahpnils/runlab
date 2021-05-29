# runlab

`runlab` is a script shell that starts and stops a list of libvirt domains and networks.

## Usage

Usage : `./runlab.sh [-skrch]`.
Option `-s` starts the lab.
Option `-k` stops (kills) the lab.
Option `-r` restarts (stops then starts) the lab
Option `-c` specifies the config file (defaults to /etc/runlabrc)
Option `-h` shows a very resembling help message.

## Configuration file

For now the configuration file location is hardcoded in `/etc/runlabrc`.
The `runlabrc.example` in this repository is a heavily-documentend version.

## License

BSD-3-Clause License.

## Misc.

Any help is welcome :-)
