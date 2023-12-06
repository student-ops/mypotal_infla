#!/bin/bash
yum update -y
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config