#!/bin/bash
kubectl apply -f nginx-demo-namespace.yaml
kubectl apply -f nginx-demo-resource-quota.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-node-port-service.yaml