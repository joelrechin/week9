resource "aws_iam_role" "week9-role" {
  name               = "week9-role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "AllowEc2ToUseThisRole",
"Action": "sts:AssumeRole",
"Principal": {
"Service": "ec2.amazonaws.com"
},
"Effect": "Allow"
}
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "week9-role" {
  role       = aws_iam_role.week9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
