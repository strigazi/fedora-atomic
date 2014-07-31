#!/bin/bash
# Copyright (C) 2014 Colin Walters <walters@verbum.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

set -e
set -x

tmpdir=$(mktemp -d)

. $(dirname $0)/config.sh

imagestmpdir=${tmpdir}/images

imgtarget=${imagestmpdir}/${OSNAME}.qcow2
imgtargetinstaller=${imagestmpdir}/install/${OSNAME}-installer.iso
imgtargetcloud=${imagestmpdir}/cloud/${OSNAME}.qcow2
imgtargetvagrantlibvirt=${imagestmpdir}/vagrant-libvirt/${OSNAME}.box

mkdir -p ${imagestmpdir}

if test -z "${YUM_BASEURL}"; then
    case ${RELEASE} in
	rawhide|21) YUM_BASEURL=http://download.fedoraproject.org/pub/fedora/linux/development/${RELEASE}/$ARCH/os/;;
	*) YUM_BASEURL=http://download.fedoraproject.org/pub/fedora/linux/releases/${RELEASE}/$ARCH/os/
    esac
fi

if test -n "${LOCAL_OVERRIDES}"; then
    LORAX_LOCAL_OVERRIDES="-s ${LOCAL_OVERRIDES}"
fi

if test -n "${http_proxy}"; then
    LORAX_PROXY="--proxy ${http_proxy}"
fi

lorax --add-template=${WORKDIR}/fedora-atomic/lorax-embed-repo.tmpl ${LORAX_PROXY} --add-template-var=ostree_repo=${OSTREE_REPO} --add-template-var=ostree_ref=${REF} -p "${OS_PRETTY_NAME}" -v "${RELEASE}" -r "${RELEASE}" -s "${YUM_BASEURL}" ${LORAX_LOCAL_OVERRIDES} "${tmpdir}/lorax"

# Cherry pick just one bit from lorax
mkdir -p $(dirname ${imgtargetinstaller})
mv ${tmpdir}/lorax/images/boot.iso ${imgtargetinstaller}

# Create base image
rpm-ostree-toolbox create-vm-disk "${OSTREE_REPO}" "${OSNAME}" "${REF}" "${imgtarget}"

# Cloud image
mkdir -p $(dirname "${imgtargetcloud}")
cp "${imgtarget}" "${imgtargetcloud}"
cat >cloud-postprocess.json <<EOF
{
	"commands":
	[
	    { "name": "systemctlenable",
	      "units": ["cloud-init.service",
			"cloud-init-local.service",
			"cloud-config.service",
			"cloud-final.service"] },
            { "name": "appendkernelargs",
              "args": ["console=tty1", "console=ttyS0,115200n8"] }
	]
}
EOF
rpm-ostree-toolbox postprocess-disk "${imgtargetcloud}" $(pwd)/cloud-postprocess.json
rm cloud-postprocess.json
xz "${imgtargetcloud}"

# Vagrant box
tmpqcow=${imagestmpdir}/vagrant-libvirt/${OSNAME}.qcow2
mkdir -p $(dirname "${tmpqcow}")
cp "${imgtarget}" "${tmpqcow}"

cat > vagrant-prep <<EOF
#!/bin/bash
set -e
set -x
if ! getent passwd vagrant 1>/dev/null; then useradd vagrant; fi
echo "vagrant" | passwd --stdin vagrant
if ! groups vagrant | grep wheel; then usermod -a -G wheel vagrant; fi
sed -i 's,Defaults\\s*requiretty,Defaults !requiretty,' /etc/sudoers
echo '%wheel ALL=NOPASSWD: ALL' > /etc/sudoers.d/vagrant-nopasswd-wheel
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
mkdir -m 0700 -p ~vagrant/.ssh
cat > ~vagrant/.ssh/authorized_keys << EOKEYS
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOKEYS
chmod 600 ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh/
touch /var/vagrant-prep.done
EOF

cat > vagrant-prep.service <<EOF
[Unit]
Description=Initialize vagrant
Before=sshd.service
ConditionPathExists=!/var/vagrant-prep.done

[Service]
ExecStart=/usr/sbin/vagrant-prep
Type=oneshot
EOF

cat >vagrant-postprocess.json <<EOF
{
	"commands":
	[
	    { "name": "systemctlmask",
	      "units": ["cloud-init.service",
			"cloud-init-local.service",
			"cloud-config.service",
			"cloud-final.service"] },
	    { "name": "injectservice",
	      "unit": "vagrant-prep.service",
	      "script": "vagrant-prep" },
	    { "name": "systemctlenable",
	      "units": [ "vagrant-prep.service" ] }
	]
}
EOF

rpm-ostree-toolbox postprocess-disk "${tmpqcow}" $(pwd)/vagrant-postprocess.json

cat > Vagrantfile <<EOF
Vagrant.configure("2") do |config|
  config.vm.box = "atomic"

  config.vm.synced_folder './', '/vagrant', type: 'rsync', disabled: true

  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 2
    v.customize ["modifyvm", :id, "--cpus", "4"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    # No guest additions
    v.check_guest_additions = false
    v.functional_vboxsf = false
  end
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 2
    libvirt.memory = 1024
    libvirt.driver = 'kvm' # needed for kvm performance benefits!
    libvirt.connect_via_ssh = false
    libvirt.username = 'root'
  end
end
EOF

cat > metadata.json <<EOF
{
  "provider"     : "libvirt",
  "format"       : "qcow2",
  "virtual_size" : 8
}
EOF

mv "${tmpqcow}" box.img

tar cjvf "${imgtargetvagrantlibvirt}" Vagrantfile metadata.json box.img
rm -f Vagrantfile metadata.json box.img

rm "${imgtarget}"

echo "Done!"
