Fedora Atomic (Host)
--------------------

Fedora Atomic is a sub-spin of the Cloud product in Fedora
that is an implementation of the Atomic Host pattern
defined by http://projectatomic.io

See the original change:
https://fedoraproject.org/wiki/Changes/Atomic_Cloud_Image
as well as the updated
https://fedoraproject.org/wiki/Changes/AtomicHost

### Tools and source files

The `fedora-atomic-docker-host.json` file is the core manifest
defining what goes into the host (ostree) content.

The `rpm-ostree` tool is invoked inside Fedora rel-eng; see:
https://git.fedorahosted.org/cgit/releng/tree/scripts/run-pungi#n48 

This git repository holds the core manifest file
`fedora-atomic-docker-host.json` that is used for that process.

That tree lands in one of the versioned repositories here:
http://dl.fedoraproject.org/pub/fedora/linux/atomic/

### Cloud images

Cloud (VM) images are generated inside Koji (using ImageFactory ->
Anaconda), using the tree content (note use of the `ostreesetup`
Kickstart verb).

The images are started via the above releng git repository, and
a list of Koji tasks can be found here:

http://koji.fedoraproject.org/koji/tasks?state=all&owner=masher&view=flat&method=createImage&order=-id

### Installer and PXE-to-Live

See http://dl.fedoraproject.org/pub/fedora/linux/atomic/





