################################################################
# REQUIRED VARIABLES
################################################################

variable "cluster_name" {
  description = "The name of the ECS cluster."
  type        = string

}

###############################################################
# OPTIONAL VARIABLES
###############################################################


variable "cloudwatch_log_group_retention_in_days" {
  description = "The number of days to retain log events."
  type        = number
  default     = 7

}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html
variable "cloudwatch_log_group_class" {
  description = "The class of the CloudWatch Log Group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS`. Default is `INFREQUENT_ACCESS`."
  type        = string
  default     = "INFREQUENT_ACCESS"
}

variable "tags" {
  description = "A map of tags to assign to the ECS cluster."
  type        = map(string)
  default     = {}

}
