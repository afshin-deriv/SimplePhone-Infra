variable "db_instance" {
  description = "DB instance type"
  type        = string
  default     = "db.t3.small"
}

variable "multi_az" {
  description = "Enable/Disable Amazon RDS Multi-AZ deployment feature. Amazon RDS provides high availability and failover support for DB instances using Multi-AZ deployments. In a Multi-AZ deployment, Amazon RDS automatically provisions and maintains a synchronous standby replica in a different Availability Zone."
  type        = string
  default     = true
}

variable "allocated_storage" {
  description = "The allocated storage in gibibytes"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "To enable Storage Autoscaling with instances that support the feature, define the max_allocated_storage argument higher than the allocated_storage argument."
  type        = number
  default     = 50
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created. Must contain 1 to 64 letters or numbers and Can't be a word reserved by the specified database engine"
  type        = string
  default     = "simplephone"
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of io1."
  type        = string
  default     = 0
}

variable "maintenance_window" {
  description = "The window to perform maintenance in."
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled."
  type        = string
  default     = "00:00-01:30"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = string
  default     = false
}

variable "storage_type" {
  default     = "gp2"
  type        = string
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)."
}

variable "engine_version" {
  type        = string
  description = "The engine version to use."
  default     = "5.7"
}

variable "parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to associate."
  default     = "default.mysql5.7"
}

variable "backup_retention_period" {
  default     = "10"
  type        = string
  description = "The days to retain backups for. Must be between 0 and 35."
}

variable "allow_major_version_upgrade" {
  default     = true
  type        = string
  description = "Indicates that major version upgrades are allowed."
}

variable "auto_minor_version_upgrade" {
  default     = true
  type        = string
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window.."
}

variable "username" {
  type        = string
  description = "Username for the master DB user."
  default     = "admin"
}

variable "iam_database_authentication_enabled" {
  default     = true
  type        = string
  description = "Specifies whether or mappings of IAM accounts to database accounts is enabled."
}

variable "rds_port" {
  default     = 3306
  type        = string
  description = "The port on which the DB accepts connections."
}

variable "deletion_protection" {
  default     = true
  type        = string
  description = "If the DB instance should have deletion protection enabled."
}

variable "password_payload" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "rds-sg_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}