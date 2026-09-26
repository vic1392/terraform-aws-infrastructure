# ---------- Random password (if not provided) ----------
resource "random_password" "master" {
  count = var.password == null ? 1 : 0

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  master_password = var.password != null ? var.password : random_password.master[0].result
}

# ---------- DB Subnet Group ----------
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# ---------- Parameter Group ----------
resource "aws_db_parameter_group" "this" {
  count = length(var.parameters) > 0 ? 1 : 0

  name   = "${var.identifier}-pg"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-pg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Derive parameter group family from engine + major version
  engine_major      = var.engine_version != null ? split(".", var.engine_version)[0] : null
  parameter_group_family = local.engine_major != null ? "${var.engine}${local.engine_major}" : null
}

# ---------- RDS Instance ----------
resource "aws_db_instance" "this" {
  identifier = var.identifier
  engine     = var.engine
  engine_version = var.engine_version

  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type           = var.storage_type
  storage_encrypted      = var.storage_encrypted
  kms_key_id             = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = local.master_password
  port     = var.port

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  parameter_group_name   = length(var.parameters) > 0 ? aws_db_parameter_group.this[0].name : null

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval

  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"

  apply_immediately = false

  tags = merge(var.tags, {
    Name = var.identifier
  })

  lifecycle {
    ignore_changes = [password]   # don't rotate password on every apply
  }
}

# ---------- Read Replica (optional) ----------
resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? 1 : 0

  identifier          = "${var.identifier}-replica"
  replicate_source_db = aws_db_instance.this.identifier

  instance_class    = var.replica_instance_class != null ? var.replica_instance_class : var.instance_class
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  # Replicas inherit most settings; only a few can differ
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval

  tags = merge(var.tags, {
    Name = "${var.identifier}-replica"
  })
}

# ---------- Secrets Manager (optional — stores connection info) ----------
resource "aws_secretsmanager_secret" "this" {
  name                    = "${var.identifier}-credentials"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.identifier}-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  secret_string = jsonencode({
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    db_name  = var.db_name
    username = var.username
    password = local.master_password
  })
}
