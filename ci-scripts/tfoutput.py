import sys
import json

# mapping of terraform out variables to environment variables required by services
mapping = {
    "workers_role_name": "",
    "workers_security_group_name": "",
    "workers_role_arn": "",
    "eks_cluster_endpoint": "",
    "eks_cluster_security_group_name": "",
    "workers_security_group_id": "",
    "workers_autoscaling_group_arn": "",
    "workers_launch_template_arn": "",
    "eks_cluster_version": "",
    "workers_autoscaling_group_health_check_grace_period": "",
    "eks_cluster_security_group_arn": "",
    "redis_endpoint": "",
    "workers_autoscaling_group_default_cooldown": "",
    "eks_cluster_id": "EKS_CLUSTER_NAME",
    "workers_autoscaling_group_id": "",
    "workers_autoscaling_group_health_check_type": "",
    "ecr_url": "REGISTRY_URL",
    "workers_autoscaling_group_desired_capacity": "",
    "vpc_default_security_group_id": "",
    "workers_autoscaling_group_min_size": "",
    "eks_cluster_security_group_id": "",
    "workers_security_group_arn": "",
    "eks_cluster_arn": "",
    "ecr_name": "AWS_ECR_REPO_NAME",
    "workers_launch_template_id": "",
    "workers_autoscaling_group_name": "",
    "vpc_id": "",
    "workers_autoscaling_group_max_size": "",
    "vpc_cidr_block": "",
}

lines = sys.stdin.read()
parsed_lines = json.loads(lines)


def from_stdin():
    return sys.stdin.read()


def transform(payload):
    result = {}

    for key, val in payload.items():
        if val["type"] != "string":
            continue

        if key in mapping and mapping[key]:
            result[mapping[key]] = val["value"]

    return result


def parse_argv():
    args = sys.argv[1:]
    result = {}

    for arg in args:
        fields = arg.split("=")

        if len(fields) < 2:
            continue
        result[fields[0]] = fields[1]

    return result


def combine(a, b):
    result = {}

    for key, val in a.items():
        result[key] = val

    for key, val in b.items():
        result[key] = val

    return result


def main():
    payload = from_stdin()
    parsed_payload = json.loads(lines)
    desired = transform(parsed_payload)
    sys_args = parse_argv()
    result = combine(desired, sys_args)
    print(json.dumps(result))


if __name__ == "__main__":
    main()
