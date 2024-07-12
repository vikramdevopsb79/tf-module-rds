resource "aws_db_instance" "main" {
  identifier             = "${var.env}-rds"
  allocated_storage      = 10
  db_name                = "dummy_default"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = jsondecode(data.vault_generic_secret.rds.data_json).username
  password               = jsondecode(data.vault_generic_secret.rds.data_json).password
  parameter_group_name   = aws_db_parameter_group.main.name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.env}-rds-pg"
  family = var.family
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-rds-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "main" {
  name        = "${var.env}-rds-sg"
  description = "${var.env}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.eks_subnet_cidr
    description = "MYSQL Port"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

