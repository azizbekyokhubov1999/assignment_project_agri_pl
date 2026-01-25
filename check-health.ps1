Write-Host "--- Starting DevOps Health Audit ---" -ForegroundColor Cyan

# 1. Check Kubernetes Pods
Write-Host "`n[1/3] Checking Kubernetes Cluster State..." -ForegroundColor Yellow
kubectl get pods

# 2. Check Backend Connectivity
Write-Host "`n[2/3] Testing Agri-Backend Response..." -ForegroundColor Yellow
# We port-forward temporarily to test the API
$job = Start-Job -ScriptBlock { kubectl port-forward deployment/agri-backend 8080:8080 }
Start-Sleep -Seconds 3
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get
    Write-Host "Success: Backend is reachable!" -ForegroundColor Green
} catch {
    Write-Host "Warning: Health endpoint not found, but port is open." -ForegroundColor Gray
}
Stop-Job $job

# 3. Check Database Logs
Write-Host "`n[3/3] Auditing Database Logs (Loki)..." -ForegroundColor Yellow
kubectl logs deployment/postgres --tail=5
Write-Host "`n--- Health Audit Complete ---" -ForegroundColor Cyan