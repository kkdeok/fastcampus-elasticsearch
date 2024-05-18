resource "aws_security_group" "elastic_sg" {
  name        = "elastic-sg"
  description = "Security group for Elastic"

  # SSH 포트(22번) 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TCP 포트 9200 허용
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TCP 포트 9300-9399 허용
  ingress {
    from_port   = 9300
    to_port     = 9399
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TCP 포트 5601 허용
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 모든 트래픽을 외부로 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}