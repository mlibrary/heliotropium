#!/bin/bash
kubectl apply -f fulcimen-demo-namespace.yaml
#kubectl apply -f fulcimen-demo-resource-quota.yaml
kubectl apply -f mysql-external-name-service.yaml
kubectl apply -f mysql-client-alpine-pod.yaml
kubectl apply -f fulcimen-deployment.yaml
kubectl apply -f fulcimen-node-port-service.yaml