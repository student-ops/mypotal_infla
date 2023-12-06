yum install -y amazon-efs-utils
yum install -y git
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
sudo yum install -y amazon-efs-utils