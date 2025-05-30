Ticket logs
kubectl logs -f -l app.kubernetes.io/fullname=staging-ticket-backend-api --since=0s -n carro-ticket

Fluentbit logs
kubectl logs -f -l app.kubernetes.io/instance=fluent-bit --all-containers=true --max-log-requests=16 -n logging | grep "LUA_FILTER"
