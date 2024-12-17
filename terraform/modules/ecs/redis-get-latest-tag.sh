# This script retrieves the Docker image tag for a specified container within an ECS task definition.
# It accepts two optional arguments: the task definition name and the container name.
# If no arguments are provided, it defaults to 'web' for both the task definition and container name.
# The script then uses the AWS CLI to describe the task definition and extracts the Docker image tag
# for the specified container using 'jq' for JSON parsing.

# Arguments:
# 1. task_definition - Name of the ECS task definition (default: 'web').
# 2. container_name - Name of the container within the ECS task definition (default: 'web').

task_definition=${1:-'redis-task-definition'}
container_name=${2:-'redis'}
taskdef=$(aws ecs describe-task-definition --task-definition "$task_definition" --region eu-west-1)
loc=$(echo $taskdef | jq -r '[.taskDefinition.containerDefinitions[] | .name=="'$container_name'"]|index(true)')
tag=$(echo $taskdef | jq -r --arg TASK "$container_name" '.taskDefinition.containerDefinitions[] | select(.name==$TASK) | .image' | sed 's/.*://')
echo "{\"tag\": \"${tag}\"}"