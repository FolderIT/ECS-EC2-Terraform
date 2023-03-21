##### ECS-Cluster #####
resource "aws_ecs_cluster" "cluster" {
  name = "ecs-folderit-cluster"
}

##### AWS ECS-TASK #####
resource "aws_ecs_task_definition" "task_definition" {
  container_definitions    = data.template_file.task_definition_json.rendered # task defination json file location
  family                   = "folderit-task-defination-webservice"            # task name
  network_mode             = "bridge"                                         # network mode awsvpc, brigde
  memory                   = "256"
  cpu                      = "256"
  requires_compatibilities = ["EC2"] # Fargate or EC2
}

data "template_file" "task_definition_json" {
  template = file("task_definition.json")

  vars = {
    CONTAINER_IMAGE = var.container_image
  }
}

##### AWS ECS-SERVICE #####
resource "aws_ecs_service" "service-webservice" {
  cluster         = aws_ecs_cluster.cluster.id                  # ECS Cluster ID
  desired_count   = 1                                           # Number of tasks running
  launch_type     = "EC2"                                       # Cluster type [ECS OR FARGATE]
  name            = "folderit-webservice-service-webservice"    # Name of service
  task_definition = aws_ecs_task_definition.task_definition.arn # Attach the task to service
  load_balancer {
    container_name   = "folderit-webservice"
    container_port   = "80"
    target_group_arn = aws_alb_target_group.alb_public_webservice_target_group.arn
  }
}
