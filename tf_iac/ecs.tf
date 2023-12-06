resource "aws_ecs_cluster" "myinfla_cluster" {
  name = "myinfla-cluster"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ec2_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx",
      image     = "nginx:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "nginx_test_service" {
  name            = "myinfla-nginx-service"
  cluster         = aws_ecs_cluster.myinfla_cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  launch_type     = "EC2"
  desired_count   = 2

  deployment_controller {
    type = "ECS"
  }
}
