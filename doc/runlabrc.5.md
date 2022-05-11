% RUNLABRC(5)
% Nils Ratusznik
% May 2022

# NAME

runlabrc - runlab configuration file

# SYNOPSIS

/etc/runlabrc

# DESCRIPTION

The **runlabrc** file contains the lists of which domains and network to start
or stop in **runlab**(1). The file is a bash script sourced by **runlab**(1),
and the variables are :

**libvirt_uri** (mandatory): location of the libvirt hypervisor. The default
value is "qemu:///system", which connects to the local host. A remote system
can be accessed with the following URI : *qemu+ssh://user@hypervisor/system*

**net_list** (mandatory): list of libvirt's virtual networks to start or stop.

**dom_list** (mandatory): list of libvirt's domains, aka virtual machines, to
start or stop.

For both **net_list** **dom_list**, the list is run from top to bottom when
runlab starts the lab, and from bottom to top when runlab stops the lab. So the
first domain and network to start is the last to stop. Networks are started
before domains, but domains are stopped before networks.

# FILES

/etc/runlabrc

# EXAMPLE

Below is an example *runlabrc* configuration file.

libvirt_uri="qemu:///system"

net_list=" \
examplenet1 \
default \
"

dom_list=" \
examplevm1 \
examplevm2 \
"

# SEE ALSO

runlab(1), virsh(1)
