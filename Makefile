
install-requirements:
	pip3 install -r requirements.txt

check-env-setup:
	python3 -c 'from utils import check_environment_variables;  check_environment_variables()';

cloudformation-validate: install-requirements check-env-setup
	python3 -c 'from deploy_cloudformation import validate_templates;  validate_templates()';

infra-deploy: cloudformation-validate
	python3 -c 'from deploy_cloudformation import create_or_update_stacks;  create_or_update_stacks(is_foundation=True)';

push-to-ecr:
	python3 -c 'from deploy_docker import update_airflow_image;  update_airflow_image()';

airflow-deploy: infra-deploy push-to-ecr
	python3 -c 'from deploy_cloudformation import create_or_update_stacks;  create_or_update_stacks(is_foundation=False)';
	python3 -c 'from deploy_cloudformation import log_outputs;  log_outputs()';

airflow-push-image: push-to-ecr
	python3 -c 'from deploy_cloudformation import restart_airflow_ecs;  restart_airflow_ecs()';

airflow-destroy:
	python3 -c 'from deploy_cloudformation import destroy_stacks;  destroy_stacks()';

airflow-local:
	pip3 install cryptography
	export AIRFLOW_FERNET_KEY=$(shell python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
	docker-compose up --build
