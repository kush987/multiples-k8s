# Kubernetes YAML Files Overview

Kubernetes YAML files (also called **manifests**) are declarative
configs that describe what you want in the cluster.\
You can put everything in **one file (separated by `---`)** or **split
into multiple files** for clarity.

------------------------------------------------------------------------

## 🔹 Common Kubernetes YAML Types

### 1. Workload (Pods, Deployments, StatefulSets, DaemonSets, Jobs, CronJobs)

-   **Pod** -- the smallest unit, runs 1+ containers.\
-   **Deployment** -- manages replicas of Pods, does rolling updates.\
-   **ReplicaSet** -- keeps the right number of Pods running (usually
    created by a Deployment).\
-   **StatefulSet** -- like Deployment, but with stable IDs & storage
    (databases, Kafka, etc).\
-   **DaemonSet** -- 1 pod per node (monitoring agents, log
    collectors).\
-   **Job / CronJob** -- run batch tasks once or on a schedule.

📄 Example: `deployment.yaml`

------------------------------------------------------------------------

### 2. Service (Networking inside cluster)

-   **ClusterIP (default)** -- exposes service **inside cluster** only.\
-   **NodePort** -- exposes service on **node's IP:port** → reachable
    from host/VM.\
-   **LoadBalancer** -- gets a cloud load balancer (AWS ELB, GCP LB,
    etc).\
-   **Headless Service** (`clusterIP: None`) -- gives direct pod DNS.

📄 Example: `service.yaml`

------------------------------------------------------------------------

### 3. Ingress (External access via HTTP/HTTPS)

-   Routes external traffic to services.\
-   Needs an **Ingress Controller** (like Nginx Ingress, Traefik,
    Istio).

📄 Example: `ingress.yaml`

------------------------------------------------------------------------

### 4. Config & Secrets (App configuration)

-   **ConfigMap** -- stores non-sensitive config (env vars, config
    files).\
-   **Secret** -- stores passwords, API keys (base64 encoded).

📄 Examples: `configmap.yaml`, `secret.yaml`

------------------------------------------------------------------------

### 5. Storage

-   **PersistentVolume (PV)** -- physical storage in cluster.\
-   **PersistentVolumeClaim (PVC)** -- pod's request for storage.\
-   **StorageClass** -- defines dynamic storage provisioning.

📄 Example: `storage.yaml`

------------------------------------------------------------------------

### 6. RBAC (Security)

-   **ServiceAccount** -- identity for pods.\
-   **Role / ClusterRole** -- defines permissions.\
-   **RoleBinding / ClusterRoleBinding** -- assigns permissions to
    users/pods.

📄 Example: `rbac.yaml`

------------------------------------------------------------------------

### 7. Namespace

-   Virtual cluster inside Kubernetes.\
-   Helps organize and isolate resources.

📄 Example: `namespace.yaml`

------------------------------------------------------------------------

## 🔹 How many YAMLs do you *need*?

For a typical **app deployment** (like a Spring Boot app), you usually
need:

1.  **Deployment** → defines pods & replicas.\
2.  **Service** → exposes pods.\
3.  **Ingress** (optional) → if you want one stable URL instead of
    NodePort.\
4.  **ConfigMap/Secret** (optional) → if your app needs configs or
    passwords.\
5.  **PersistentVolume/PVC** (optional) → if your app needs storage.

👉 So **2 files minimum** (Deployment + Service) is enough to run most
apps.\
👉 Add more YAMLs as your app grows in complexity.

------------------------------------------------------------------------

✅ Pro tip: You can combine multiple manifests in a single `.yaml` file
by separating them with `---`.
