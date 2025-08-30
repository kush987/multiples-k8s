===============================================================================
Kubernetes Local Lab with Multipass (MicroK8s)
===============================================================================

🔹 1. Why use Multipass for Kubernetes?

• Multipass creates Ubuntu VMs easily. • Each VM can act as a Kubernetes
node. • Simulate a multi-node cluster on your laptop/desktop. • Works
with MicroK8s, k3s, or full kubeadm.

------------------------------------------------------------------------

🔹 2. Recommended Lightweight Options

  Option Description
  --------------------------------------------------------------------
  MicroK8s Canonical's lightweight Kubernetes. Great for local dev.
  Can run single-node or multi-node.
  k3s Lightweight Kubernetes by Rancher. Low resource usage.
  kubeadm Full Kubernetes installation. More complex, but realistic.

💡 Tip: Start with MicroK8s --- easiest to set up on Multipass.

------------------------------------------------------------------------

🔹 3. Steps to Setup Kubernetes Cluster with Multipass

Step 1: Install Multipass VM by following the link https://canonical.com/multipass and  Launch VMs

\# Master node 
`multipass launch -n k8s-master -c 2 -m 4G -d 20G`

\# Worker nodes 
`multipass launch -n k8s-worker1 -c 2 -m 2G -d 10G`
`multipass launch -n k8s-worker2 -c 2 -m 2G -d 10G`

Step 2: Install MicroK8s

\# On each VM 
`multipass exec <vm-name> {=html} -- sudo snap install microk8s --classic`

\# Add your user to microk8s group (inside VM) multipass exec
`<vm-name> -- sudo usermod -a -G microk8s ubuntu multipass exec`
`<vm-name> -- sudo chown -f -R ubuntu \~/.kube`

\# Enable common add-ons (on master) 
`multipass exec k8s-master -- microk8s enable dns dashboard storage`

Step 3: Join Worker Nodes to Master

\# On master, get join token 
`multipass exec k8s-master -- microk8s add-node`

\# Example output: \# `microk8s join 10.41.236.101:25000/<token>`

\# Run join command on each worker VM 
`multipass exec k8s-worker1 -- <join command>` 
`multipass exec k8s-worker2 -- <join command>`

Step 4: Verify Cluster

`multipass exec k8s-master -- microk8s kubectl get nodes`

\# Should show 3 nodes: 1 master + 2 workers

Step 5: Access Dashboard (Optional)

`multipass exec k8s-master -- microk8s dashboard-proxy`

\# Provides a URL to access Kubernetes Dashboard from host

------------------------------------------------------------------------

🔹 4. Tips

• Use private IPs of VMs for joining nodes (`multipass list` shows IPs)
• Allocate enough CPU & RAM for smooth operation • To access services
from host: use port forwarding or bridged networking

------------------------------------------------------------------------

🔹 5. Next Steps

• Deploy sample apps using kubectl • Learn core concepts: Pods,
Deployments, Services, Ingress • Experiment with scaling nodes, rolling
updates, and networking

===============================================================================
\# docker image push to local kube8s registry 
  `sudo vim /etc/docker/daemon.json`

add this `{ "insecure-registries": \["<mastervm-ip>:32000"\] }`

`sudo systemctl restart docker`

#docker image Push to local kube8s reistry

`docker tag multiple-app:latest <mastervm-ip>:32000/multiple-app:latest`

`docker push <mastervm-ip>:32000/multiple-app:latest`

#Apply the deployment file 
`multipass exec k8s-master -- microk8s kubectl apply -f spring-boot-deployment.yaml`

#rollout status of pods 
`microk8s kubectl rollout status deployment/springboot-app`

#explictly set images local (optional)
`microk8s kubectl set image deployment/springboot-app springboot=10.41.236.22:32000/multiple-app:local`

# some command to deleteing deployment service

`microk8s kubectl delete deployment springboot-app` 
`microk8s kubectl delete service springboot-service` 
`microk8s kubectl apply -f spring-boot-development.yaml`

#delete pods 
`microk8s kubectl get pods -l app=springboot`

# if localregistry images are not able to pick beacuse kube8s runs on http insted of https

On all nodes (master + workers):

`multipass exec k8s-master -- sudo vim /var/snap/microk8s/current/args/containerd-template.toml`

Find the `\[plugins."io.containerd.grpc.v1.cri".registry\]` section.

Add your registry as insecure:

`\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."10.41.236.22:32000"\]`
`endpoint = \["http://10.41.236.22:32000"\]`

#Repeat on worker nodes:

`multipass exec k8s-worker1 -- sudo vim /var/snap/microk8s/current/args/containerd-template.toml 
`multipass exec k8s-worker2 -- sudo nano /var/snap/microk8s/current/args/containerd-template.toml`

`multipass exec k8s-master -- microk8s stop` 
`multipass exec k8s-master -- microk8s start`

`multipass exec k8s-worker1 -- microk8s stop` 
`multipass exec k8s-worker1 -- microk8s start`

`multipass exec k8s-worker2 -- microk8s stop` 
`multipass exec k8s-worker2 -- microk8s start`

Note: its shows working mirror is deprecated or future release issue we need
to replace with config_path
