resource "aws_iam_role" "k8s_instances" {
  name               = "k8s_hard_way_instances"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "k8s_instances" {
  name = "k8s_hard_way_instances"
  role = aws_iam_role.k8s_instances.name
}

resource "aws_iam_role_policy_attachment" "aws_ssm_managed_instance_core" {
  role       = aws_iam_role.k8s_instances.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
