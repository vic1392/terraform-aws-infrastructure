variable "identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
}

variable "engine" {
  description = "Database engine: mysql, postgres, mariadb, oracle-*, sqlserver-*"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["mysql", "postgres", "mariadb"], var.engine)
    error_message = "engine must be one of: mysql, postgres, mariadb."
  }
}

variable "engine_version" {
  description = "Engine version (leave null to use AWS default)"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max storage for autoscaling (0 disables)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type: gp2, gp3, io1, io2"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master password (leave null to auto-generate)"
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  description = "Database port (null = engine default)"
  type        = number
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "Days to retain backups (0 disables)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion (true for dev)"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent accidental deletion"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "storage_encrypted" {
  description = "Encrypt storage at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key for encryption (null = AWS managed)"
  type        = string
  default     = null
}

variable "create_read_replica" {
  description = "Create a read replica"
  type        = bool
  default     = false
}

variable "replica_instance_class" {
  description = "Instance class for the read replica (null = same as primary)"
  type        = string
  default     = null
}

variable "parameters" {
  description = "Map of DB parameters to apply"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
