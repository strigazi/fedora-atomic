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
  - To submit patches https://lists.fedoraproject.org/pipermail/rel-eng/
  - No public log output currently, dgilmore may tell you if it breaks

This git repository holds the core manifest file
`fedora-atomic-docker-host.json` that is used for that process.


### Cloud images

Cloud (VM) images are generated inside Koji (using ImageFactory ->
Anaconda), using the tree content (note use of the `ostreesetup`
Kickstart verb).

The spin-kickstarts for Fedora is here:
https://git.fedorahosted.org/git/spin-kickstarts.git

The images are started via the above releng git repository, and
a list of Koji tasks can be found here:

http://koji.fedoraproject.org/koji/tasks?state=all&owner=masher&view=flat&method=createImage&order=-id

### Installer and PXE-to-Live

Installer is different for 2 reasons:
 - Embeds content
 - Uses different partitioning scheme
   - https://github.com/projectatomic/fedora-productimg-atomic
 - https://git.fedorahosted.org/cgit/spin-kickstarts.git/tree/atomic-installer
 - lorax --nomacboot  -p 'Fedora Atomic' -v 22 -r 22 --source=http://127.0.0.1/repomirror/fedora-22 --add-template /srv/fedora-atomic/spin-kickstarts/atomic-installer/lorax-configure-repo.tmpl --add-template-var=ostree_osname=fedora-atomic  --add-arch-template-var=ostree_repo=http://127.0.0.1/fedora-atomic/repo --add-template-var=ostree_ref=fedora-atomic/f22/x86_64/docker-host --add-arch-template /srv/fedora-atomic/spin-kickstarts/atomic-installer/lorax-embed-repo.tmpl --add-arch-template-var=ostree_osname=fedora-atomic --add-arch-template-var=ostree_ref=fedora-atomic/f22/x86_64/docker-host -i fedora-productimg-atomic /var/tmp/lorax

https://fedorahosted.org/rel-eng/ticket/6119

http://dl.fedoraproject.org/pub/fedora/linux/atomic/





