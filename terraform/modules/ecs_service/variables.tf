####################################################################
# REQUIRED VARIABLES
####################################################################

variable "name" {
  description = "The name of the ECS service."
  type        = string
}

variable "cluster_arn" {
  description = "The ARN of the ECS cluster."
  type        = string
}

variable "cpu" {
  description = "The number of CPU units to reserve for the task."
  type        = number
}

variable "memory" {
  description = "The amount of memory (in MiB) to reserve for the task."
  type        = number
}


variable "container_definitions" {
  description = "A map of valid ECS container definitions."
  type        = any # NOTE: The type 'any' is used here to allow flexibility in the structure of the container definitions.
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the service."
  type        = list(string)
}


#####################################################################
# OPTIONAL VARIABLES
#####################################################################

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task."
  type        = string
  default     = "awsvpc"

}


variable "security_group_rules" {
  description = "A map of security group rules to apply to the ECS service."
  type = map(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
    # Either cidr_blocks or source_security_group_id must be defined, but not both.
    cidr_blocks              = optional(list(string), null)
    source_security_group_id = optional(string, null)
  }))
  # NOTE: Terraform's type system cannot enforce mutual exclusivity between fields directly.
  # You must enforce at least one of cidr_blocks or source_security_group_id is set via validation rules.
  validation {
    condition = alltrue([
      for rule in values(var.security_group_rules) :
      (
        (rule.cidr_blocks != null && rule.source_security_group_id == null) ||
        (rule.cidr_blocks == null && rule.source_security_group_id != null)
      )
    ])
    error_message = "Each security group rule must define either 'cidr_blocks' or 'source_security_group_id', but not both."
  }


  default = {}

}

variable "launch_type" {
  description = "The launch type on which to run the service. Valid values are 'EC2' or 'FARGATE'."
  type        = string
  default     = "FARGATE"
}

variable "tags" {
  description = "A map of tags to assign to the ECS service."
  type        = map(string)
  default     = {}
}


# Autoscaling
variable "autoscaling_max_capacity" {
  description = "The maximum number of tasks in the ECS service."
  type        = number
  default     = 10

}


variable "autoscaling_min_capacity" {
  description = "The minimum number of tasks in the ECS service."
  type        = number
  default     = 1

}


variable "autoscaling_policies" {
  description = "A map of autoscaling policies for the ECS service."
  type        = any
#   default = {
#     cpu = {
#       policy_type = "TargetTrackingScaling"
#
#       target_tracking_scaling_policy_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ECSServiceAverageCPUUtilization"
#         }
#       }
#     }
#     memory = {
#       policy_type = "TargetTrackingScaling"
#
#       target_tracking_scaling_policy_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#         }
#       }
#     }
#   }
}