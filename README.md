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

It makes an OSTree commit from a set of RPM packages, which clients
then replicate.

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

### Installer

Installer is different for 2 reasons:
 - Embeds the OSTree content (unlike mainline, the OS is assembled on the server side)
 - Uses different partitioning scheme
   - https://github.com/projectatomic/fedora-productimg-atomic

To build it, you use lorax.  However, lorax presently assumes that host = target (i.e.
if you want to build a Fedora 22 Anaconda, you need a Fedora 22 host).  You can choose
to use either `mock` or `docker` (or some other container tool), or VMs of course.

Currently Fedora rel-eng runs lorax inside mock:
https://pagure.io/releng/blob/master/f/scripts/run-pungi#_62

For Project Atomic we developed rpm-ostree-toolbox which uses Docker/ImageFactory
to run lower level tools like lorax; it takes a high level config file called
`config.ini`.

However, for Fedora it is now a bit out of date because it hasn't been updated
to match how Fedora rel-eng now runs lorax; specifically the config files are duplicated
with the content in https://git.fedorahosted.org/cgit/spin-kickstarts.git/tree/atomic-installer

For some information on how this developed, see: https://fedorahosted.org/rel-eng/ticket/6119

But, to use it, get a clone of this git repo, then something like:

```
rpm-ostree-toolbox installer --ostreerepo repo -c fedora-atomic/config.ini -o installer
```

### PXE-to-Live

- dgilmore wanted QA process for gating respins of this
  (Theoretically similar to cloud image updates)
- Concern how often to respin


### Alt.fedoraproject.org: public mirror space for arbitrary content

- Server atomic01.qa.fedoraproject.org rsyncs to this
- Managed via ansible: https://github.com/cgwalters/fedora-atomic-infra
- Run rpm-ostree-toolbox by hand
  rpm-ostree-toolbox liveimage -o scratch/pxetolive --tdl fedora-atomic/fedora-atomic-22.tdl -k spin-kickstarts/fedora-cloud-atomic-pxetolive.ks -c fedora-atomic/config.ini  --overwrite

- Old style script for running composes
  https://github.com/projectatomic/rpm-ostree-toolbox/tree/master/src/scripts

- Current state: Run by hand

- New idea: set up jenkins
  - For event driven: respond to fedmsg (git commits and yum repositories)

### Gaps 

- No GPG signing (On either Fedora or CentOS)
