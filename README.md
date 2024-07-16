# Automated build of HA k3s Cluster with `kube-vip` and MetalLB

This playbook will build an HA Kubernetes cluster with `k3s`, `kube-vip` and MetalLB via `ansible`.

A continuation on Tehno Tim's k3s-ansible which aims to remove un-needed cluter from that repo and add some other interesting stuff to better suit my needs.

This is based on the work from [this fork](https://github.com/212850a/k3s-ansible) which is based on the work from [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible). It uses [kube-vip](https://kube-vip.io/) to create a load balancer for control plane, and [metal-lb](https://metallb.universe.tf/installation/) for its service `LoadBalancer`.

## How is this different from Tehno Tim's work?
Some clutter was removed (for easyer maintainence), while other more relevant stuff was added as an option during the installation.
1. Most importantly this version features a playbook with helm addons in a separate file `site_helm.yml`. For now it instals only `ingress-nginx` and `cert-manager` to the cluster. Other stuff like the prometheus stack will also be added in the near future.
2. Added advanced examples for testing the `metallb` and `ingress-nginx` functionality.
3. Removed the proxmox_lxc option (Because why would anyone want to deploy k3s cluster on lxc containers?)
4. Removed cilium networking (I belive leaving `flannel` as default and `callico` as an option was enough.)
5. Removed the raspberry_py role. I won't be using RaspberryPi anytime soon.


## 📖 k3s Ansible Playbook

Build a Kubernetes cluster using Ansible with k3s. The goal is easily install a HA Kubernetes cluster on machines running:

- [x] Debian (tested on version 11)
- [x] Ubuntu (tested on version 22.04)
- [x] Rocky (tested on version 9)

on processor architecture:

- [X] x64
- [X] arm64
- [X] armhf


## ✅ System requirements

- Control Node (the machine you are running `ansible` commands) must have Ansible 2.11+ If you need a quick primer on Ansible [you can check out my docs and setting up Ansible](https://technotim.live/posts/ansible-automation/).
- You will also need to install collections that this playbook uses by running `ansible-galaxy collection install -r ./collections/requirements.yml` (important❗)
- [`netaddr` package](https://pypi.org/project/netaddr/) must be available to Ansible. If you have installed Ansible via apt, this is already taken care of. If you have installed Ansible via `pip`, make sure to install `netaddr` into the respective virtual environment.
- `server` and `agent` nodes should have passwordless SSH access, if not you can supply arguments to provide credentials `--ask-pass --ask-become-pass` to each command.

## 🚀 Getting Started
First create a new directory based on the `sample` directory within the `inventory` directory:

```bash
cp -R inventory/sample inventory/my-cluster
```

Second, edit `inventory/my-cluster/hosts.ini` to match the system information gathered above

For example:

```ini
[master]
192.168.30.38
192.168.30.39
192.168.30.40

[node]
192.168.30.41
192.168.30.42
192.168.30.42

# Helm should be installed on one of the master nodes from which 
#  the rest of the helm packages will be installed
[master_helm]
192.168.30.38

[k3s_cluster:children]
master
node
```

###### 📄 NOTE: 

1. If multiple hosts are in the master group, the playbook will automatically set up k3s in [HA mode with etcd](https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/).
2. If you plan to use the helm addons option from site_helm.yml then you need to provide one of the master nodes into the `[master_helm]` group. This is where helm will be installed by the playbook and from this node the additional helm addons will be installed.

Finally, copy `ansible.example.cfg` to `ansible.cfg` and adapt the inventory path to match the files that you just created.

This requires at least k3s version `1.19.1` however the version is configurable by using the `k3s_version` variable.

If needed, you can also edit `inventory/my-cluster/group_vars/all.yml` to match your environment.

### ☸️ Create Cluster

#### 1. Provision the cluster
Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini
```

After deployment control plane will be accessible via virtual ip-address which is defined in inventory/group_vars/all.yml as `apiserver_endpoint`. Also a `kubeconfig` will be generated inside the repo folder.

#### 2. [Optionaly] Provision the helm addons
You can choose to select which addons are deployed or omited from the `all.yml` vars file.
After the cluster is deployed
```bash
ansible-playbook site_helm.yml -i inventory/my-cluster/hosts.ini
```

## Thanks 🤝

This repo is really standing on the shoulders of giants. Thank you to all those who have contributed and thanks to these repos for code and ideas:

- [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)
- [geerlingguy/turing-pi-cluster](https://github.com/geerlingguy/turing-pi-cluster)
- [212850a/k3s-ansible](https://github.com/212850a/k3s-ansible)
- [techno-tim/k3s-ansible](https://github.com/techno-tim/k3s-ansible)


