resource "aws_iam_role" "elastic_role" {
  name               = "elastic-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elastic_role_attachment" {
  role       = aws_iam_role.elastic_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "elastic_role_instance_profile" {
  name = "elastic-role-profile"
  role = aws_iam_role.elastic_role.id
}