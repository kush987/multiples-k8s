#!/bin/bash

# ----------------------------
# 3-node MicroK8s cluster setup on Multipass
# ----------------------------

# VM configuration
MASTER_NAME="k8s-master"
WORKER1_NAME="k8s-worker1"
WORKER2_NAME="k8s-worker2"

MASTER_MEM="4G"
WORKER_MEM="2G"

MASTER_CPU=2
WORKER_CPU=2

MASTER_DISK=20G
WORKER_DISK=10G

# ----------------------------
# 1️⃣ Launch VMs
# ----------------------------
echo "Launching VMs..."
multipass launch -n $MASTER_NAME -c $MASTER_CPU -m $MASTER_MEM -d $MASTER_DISK
multipass launch -n $WORKER1_NAME -c $WORKER_CPU -m $WORKER_MEM -d $WORKER_DISK
multipass launch -n $WORKER2_NAME -c $WORKER_CPU -m $WORKER_MEM -d $WORKER_DISK

# Wait for VMs to be ready
sleep 10

# ----------------------------
# 2️⃣ Install MicroK8s on all nodes
# ----------------------------
for vm in $MASTER_NAME $WORKER1_NAME $WORKER2_NAME; do
    echo "Installing MicroK8s on $vm..."
    multipass exec $vm -- sudo snap install microk8s --classic
    multipass exec $vm -- sudo usermod -a -G microk8s ubuntu
    multipass exec $vm -- sudo chown -f -R ubuntu ~/.kube
done

# ----------------------------
# 3️⃣ Enable add-ons on master
# ----------------------------
echo "Enabling add-ons on master..."
multipass exec $MASTER_NAME -- microk8s enable dns dashboard storage

# ----------------------------
# 4️⃣ Get master IP
# ----------------------------
MASTER_IP=$(multipass list | grep $MASTER_NAME | awk '{print $3}')
echo "Master IP: $MASTER_IP"

# ----------------------------
# 5️⃣ Generate join command
# ----------------------------
JOIN_CMD=$(multipass exec $MASTER_NAME -- microk8s add-node --token-ttl 3600 | grep microk8s | tail -1)
echo "Join command: $JOIN_CMD"

# ----------------------------
# 6️⃣ Join workers to master
# ----------------------------
for worker in $WORKER1_NAME $WORKER2_NAME; do
    echo "Joining $worker to master..."
    multipass exec $worker -- bash -c "$JOIN_CMD"
done

# ----------------------------
# 7️⃣ Verify cluster
# ----------------------------
echo "Waiting 20 seconds for nodes to join..."
sleep 20
echo "Cluster nodes:"
multipass exec $MASTER_NAME -- microk8s kubectl get nodes

echo "✅ MicroK8s 3-node cluster setup completed!"
echo "Access the master with: multipass exec $MASTER_NAME -- microk8s kubectl get nodes"

