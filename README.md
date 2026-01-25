A sample command-line application providing basic argument parsing with an entrypoint in `bin/`.

# Agri-Platform: Procurement Service & DevOps Infrastructure

##  Project Overview
This project implements a reliable, cloud-native Procurement Service for an Agricultural Platform. It utilizes a **Clean Architecture** approach in Dart, integrating distributed transaction management via the **Saga Pattern**, automated deployments through **Argo CD**, and comprehensive monitoring with **Prometheus and Grafana**.

---

##  Technical Architecture

### 1. Distributed Reliability (Saga Pattern)
To ensure data consistency across multiple databases (PostgreSQL for orders and MongoDB for audit logs), I implemented the **Procurement Saga**.
* **Database Consistency:** Uses an Outbox pattern and Isolate-based workers to ensure reliable message delivery.
* **Dual-Persistence:** PostgreSQL manages the core relational order data, while MongoDB handles the non-relational audit trails.

### 2. Infrastructure as Code (Helm)
The deployment is managed via **Helm Charts** (`agri-chart`), allowing for versioned and reproducible infrastructure.
* **Service Discovery:** Configured Kubernetes Services with specialized annotations for automated Prometheus scraping.
* **Environmental Parity:** Scalable Deployment configurations for the Agri-Backend, PostgreSQL, and MongoDB.

---

##  Continuous Delivery (GitOps)
I implemented a **GitOps workflow** using **Argo CD**. Every change pushed to the `main` branch is automatically synchronized with the Kubernetes cluster, ensuring that the live environment always matches the desired state in Git.

> docs/argocd.jpg > *Evidence: Showing the Agri-Backend, Postgres, and Mongo pods in a 'Healthy' and 'Synced' state.*

---

##  Observability & Monitoring
A core requirement was the implementation of custom business metrics and infrastructure monitoring.

### Custom Metrics Implementation
Using the `prometheus_client` library, I exposed a `/metrics` endpoint in the Dart application.
* **Metric Tracked:** `http_requests_total`
* **Labels:** Method (GET/POST), Path (/orders, /health), and Status (200, 500).

### Grafana Dashboards
I configured 7 specific panels to monitor the health and performance of the platform:
1. **CPU Utilization:** Tracks container-level resource usage.
2. **Total Requests:** Aggregate count of all incoming traffic.
3. **Success Requests:** Filtered view of HTTP 200 responses.
4. **Error Requests:** Filtered view of HTTP 500 responses for incident detection.
5. **Request Type:** Breakdown of GET vs. POST traffic.
6. **Request Path:** Identification of most-visited endpoints.
7. **Warning/Health:** A real-time heartbeat monitor (Up/Down status).

> docs/grafana_ev.jpg > *Evidence: The "Agri-Backend Daily Report" showing all 7 visualization panels.*

---

##  Local Development & Testing

### Running Locally
1. Ensure databases are accessible via port-forwarding:
   ```bash
   kubectl port-forward svc/postgres-service 5432:5432
   kubectl port-forward svc/mongodb-service 27017:27017

2. Start the server: 
 > dart bin/server.dart 

### Verifying Metrics:
 > The metrics can be verified by visiting: http://localhost:8080/metrics. 
> 
> docs/metrics.jpg 

### Server link
> http://localhost:8080/health

### Test api 
> http://localhost:8080/api/orders

### Conclusion

> This assignment demonstrates a complete DevOps lifecycle: from writing robust Dart code with error handling and design patterns to deploying it in a managed Kubernetes environment with automated monitoring.
 