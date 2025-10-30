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
  nullable    = false
}


variable "security_group_ingress_rules" {
  description = "A map of security group ingress rules to apply to the ECS service."
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))

  # NOTE: Terraform's type system cannot enforce mutual exclusivity between fields directly.
  # You must enforce either one of cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id is set via validation rules.
  validation {
    condition = alltrue([
      for rule in values(var.security_group_ingress_rules) :
      (
        length([
          for v in [
            rule.cidr_ipv4,
            rule.cidr_ipv6,
            rule.prefix_list_id,
            rule.referenced_security_group_id
          ] : v if v != null
        ]) == 1
      )
    ])
    error_message = "Each security group ingress rule must set exactly one of `cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id`."
  }

  default  = {}
  nullable = false
}


variable "security_group_egress_rules" {
  description = "A map of security group egress rules to apply to the ECS service."
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))

  validation {
    condition = alltrue([
      for rule in values(var.security_group_egress_rules) :
      (
        length([
          for v in [
            rule.cidr_ipv4,
            rule.cidr_ipv6,
            rule.prefix_list_id,
            rule.referenced_security_group_id
          ] : v if v != null
        ]) == 1
      )
    ])
    error_message = "Each security group egress rule must set exactly one of `cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id`."
  }

  default  = {}
  nullable = false
}


variable "launch_type" {
  description = "The launch type on which to run the service. Valid values are 'EC2' or 'FARGATE'."
  type        = string
  default     = "FARGATE"
  nullable    = false
}


# Autoscaling
variable "autoscaling_max_capacity" {
  description = "The maximum number of tasks in the ECS service."
  type        = number
  default     = 10
  nullable    = false
}


variable "autoscaling_min_capacity" {
  description = "The minimum number of tasks in the ECS service."
  type        = number
  default     = 1
  nullable    = false
}


variable "autoscaling_policies" {
  description = "A map of autoscaling policies for the ECS service."
  type        = any
  default = {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  }
  nullable = false
}


variable "tags" {
  description = "A map of tags to assign to the ECS service."
  type        = map(string)
  default     = {}
  nullable    = false
}


