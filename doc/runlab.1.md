% RUNLAB(1) runlab 0.1.0
% Nils Ratusznik
% May 2022

# NAME
runlab  - start and stop a group of libvirt networks and domains

# SYNOPSIS

**runlab** [**-h**] [**-s**] [**-k**] [**-r**] [**-c** config_file]

# DESCRIPTION

**runlab** starts or stops your virtual lab, composed of multiple libvirt
networks and libvirt domains.

# OPTIONS

**-h**
: displays a friendly help message.

**-s**
: starts the lab.

**-k**
: stops (kills) the lab.

**-r**
: restarts (stops then starts) the lab.

**-c** config_file
: specify the configuration file's path. When not specified, the default
configuration file (/etc/runlabrc) is used.

# SEE ALSO

runlabrc(5), virsh(1)

# BUGS

They're certainly hiding. If you find one, please report it !
