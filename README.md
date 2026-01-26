# Agri-Platform: Procurement Service & Cloud-Native Infrastructure

##  Project Overview
This project implements a high-reliability Procurement Service for an Agricultural Platform. It showcases a complete DevOps lifecycle, moving from "hardcoded" deployments to a professional **GitOps** and **Telemetry-driven** architecture.

---

##  Technical Architecture

### 1. Custom Observability (Business Metrics)
Unlike standard system metrics, this application implements **Domain-Specific Telemetry** using the `prometheus_client` library.
* **Orders Tracking:** `agri_orders_created_total` monitors procurement volume by supplier and category.
* **Saga Reliability:** `agri_saga_transactions_total` tracks the success, failure, and compensation steps of the distributed transaction.
* **System Health:** Custom `http_requests_total` with labels for method, path, and status code.

### 2. Distributed Reliability (Saga Pattern)
To ensure data consistency across **PostgreSQL** (Orders) and **MongoDB** (Audit Logs), a **Saga Pattern** was implemented.
* **Compensating Transactions:** Ensures system integrity if one database operation fails.
* **Isolate-based Workers:** Handles outbox signals asynchronously for high performance.

---

##  Infrastructure as Code (Helm)
The project has been refactored from static YAML files into a **Proper Helm Chart** to ensure dynamic, reusable deployments.
* **Dynamic Values:** All environment-specific data (images, ports, paths) is managed via `values.yaml`.
* **Templates:** Utilizes Go-templating in `k8s-deployment.yaml` and `service.yaml` for parameterization.


---

##  Continuous Delivery (GitOps)
Deployment is fully automated using **Argo CD**.
* **Automated Sync:** Argo CD monitors the GitHub repository and synchronizes the cluster state with the Helm chart.
* **Self-Healing:** Any manual changes to the cluster are automatically reverted by the Argo CD controller to maintain the "Source of Truth" in Git.

> docs/argocd.jpg

---

##  Monitoring & Dashboards
The **Agri-Backend Daily Report** in Grafana provides 7 critical visualization panels:
1. **Total Orders:** (Custom Metric) `sum(agri_orders_created_total)`.
2. **Saga Status:** (Custom Metric) Breakdown of successful vs. failed transactions.
3. **HTTP Success Rate:** Real-time monitoring of 2xx vs 5xx responses.
4. **Request Latency:** Database operation durations.
5. **CPU/Memory:** Resource utilization per pod.
6. **Path Activity:** Identification of most-hit API endpoints.
7. **System Uptime:** Real-time health status.

> docs/grafana_ev.jpg **

---

##  How to Deploy

1. **Build & Push Image:**
   ```bash
   docker build -t your-repo/agri-backend:latest .
   docker push your-repo/agri-backend:
   
2. **Install via Helm:**
   >helm upgrade --install agri-release ./agri-chart
3. **Verify Metrics: Access the metrics endpoint at:**
> http://localhost:8080/metrics


