# runlab

`runlab` is a script shell that starts and stops a list of libvirt domains and networks.


## Installation

Installation is not mandatory, you can just clone the repository and start the
script from where you cloned it.

Step 1 : clone the repository

```
git clone https://github.com/ahpnils/runlab.git
```

Step 2 : run the installer with root privileges

```
sudo make install
```

Step 3 : modify the config file to suit your needs

```
sudo vim /etc/runlabrc
```

If you wish to update your existing installation :

```
make src-update
sudo make update
```

Don't forget to have a look at the new `runlabrc.example` if new options
appeared.


## Usage

Usage : `./runlab.sh [-skrch]`.  
Option `-s` starts the lab.  
Option `-k` stops (kills) the lab.  
Option `-r` restarts (stops then starts) the lab.  
Option `-c` specifies the config file (defaults to /etc/runlabrc).  
Option `-h` shows a very resembling help message.

## Configuration file

The configuration file default location is in `/etc/runlabrc`.
The `runlabrc.example` in this repository is a heavily-documentend version.

## License

BSD-3-Clause License.

## Misc.

Any help is welcome :-)
