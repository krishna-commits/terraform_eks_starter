module "label" {
  source     = "../label"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  enabled    = var.enabled
}


resource "aws_iam_policy" "default" {
  count = var.enabled ? 1 : 0
  name = format(
    "%s%s%s",
    module.label.id,
    var.delimiter,
  "external-dns-policy")
  path = "/"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF

}


resource "aws_iam_role_policy_attachment" "default" {
  count = var.enabled ? 1 : 0

  policy_arn = join("", aws_iam_policy.default.*.arn)
  role       = var.workers_role_name
}
