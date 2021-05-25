#!/bin/bash
kubectl delete -f nginx-node-port-service.yaml
kubectl delete -f nginx-deployment.yaml
kubectl delete -f nginx-demo-resource-quota.yaml
kubectl delete -f nginx-demo-namespace.yaml
