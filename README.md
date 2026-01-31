# Agri-Platform: Procurement Service & Cloud-Native Infrastructure

##  Project Overview
This project implements a high-reliability Procurement Service for an Agricultural Platform. It showcases a complete DevOps lifecycle, moving from "hardcoded" deployments to a professional **GitOps** and **Telemetry-driven** architecture.

 **Backend**:  in dart with shelf library
 
**Database**: Postgres, MongoDb 
 
**Containerization**: 	Docker

**Orchestration**: Kubernetes

**CI/CD**:	GitHub Actions

**Package Manager**: Helm

**GitOps**:	ArgoCD

**Monitoring**:	Prometheus, Grafana, Loki



##  Technical Architecture

### CI/CD Pipeline
DevOps implementation of this project I use GitHub actions for cover CI and for CD I use ArgoCD

### GitHub Actions Workflow

![Alt text](screenshots/github_action.png)

### Repository in Docker hub
My project image in docker hub

![Alt text](screenshots/docker_hub.png)

### Kubernetes implementation

Our project deployed to kubernetes using Helm charts and managed by ArgoCD

####  Helm (Infrastructure as Code)
The project has been refactored from static YAML files into a **Proper Helm Chart** to ensure dynamic, reusable deployments.
* **Dynamic Values,** All environment-specific data (images, ports, paths) is managed via `values.yaml`.
* **Templates,** Utilizes Go-templating in `k8s-deployment.yaml` and `service.yaml` for parameterization.
*  **Database connection** file  of helm template `k8s-databases.yaml`
* 
![Alt text](screenshots/helm_proof.png)
 
###  Continuous Delivery (GitOps) with ArgoCD
Deployment is fully automated using **Argo CD**.
 Argo CD monitors the GitHub repository and synchronizes the cluster state with the Helm chart.
Any manual changes to the cluster are automatically reverted by the Argo CD controller to maintain the "Source of Truth" in Git.

**Image before sync in argo cd:**

![Alt text](screenshots/argocd1.png)

**After sync:**

![Alt text](screenshots/argocd2.png)

### Resources of Kubernetes:

![Alt text](screenshots/kubernetes_resources.png)

##  Monitoring & Dashboards

The **Agri-Backend Daily Report** in Grafana provides critical visualization panels

 ****General dashboards(Built-in dashboard):****

![Alt text](screenshots/built-in.png)
  






****Custom dashboard based on project data:****

![Alt text](screenshots/csmetrics.png)

![Alt text](screenshots/csmetrics1.png)

![Alt text](screenshots/csmetrics2.png)

**Live logs using Loki:**

![Alt text](screenshots/log.png)

## Project Structure:

agri-project/
├── .github/workflows/
│   └── build.yml               
├── agri-chart/                 
│   ├── templates/              
│   ├── values.yaml             
│   └── Chart.yaml             
├── bin/
│   └── server.dart             
├── lib/
│   ├── application/            
│   │   └── procurement_saga.dart
│   ├── core/                  
│   │   └── outbox/             
│   ├── domain/                 
│   │   ├── entities/           
│   │   ├── repositories/       
│   │   └── services/           
│   ├── infrastructure/        
│   │   ├── concurrency/        
│   │   ├── monitoring/        
│   │   ├── persistence/        
│   │   └── web/                 
├── Dockerfile                  
├── docker-compose.yml          
├── pubspec.yaml                
└── README.md                   

---

##  Development 

**Build  & Push Docker Image:**
   ```bash
   docker build -t your-repo/agri-backend:latest .
   docker push your-repo/agri-backend:
  ```
**Install via Helm:**
   >helm upgrade --install agri-release ./agri-chart

 **Verify Metrics: Access the metrics endpoint at:**
> http://localhost:8080/metrics

**Run locally:**
First we run databases in docker:

>kubectl port-forward svc/postgres-service 5432:5432
>kubectl port-forward svc/mongodb-service 27017:27017 
> Then run the application

Access to the application:
http://localhost:8080/health

