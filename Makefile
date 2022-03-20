SHELL := /bin/sh

DATE:=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_REVISION:=$(shell git rev-parse --short HEAD)
COMPOSER=podman
CONTAINERFILE=Containerfile
IMOBANCO_POD_NAME=django-pod
PSQL_SERVICE_NAME=$(IMOBANCO_POD_NAME)-service-postgres
DJANGO_SERVICE_NAME=$(IMOBANCO_POD_NAME)-service-django
KUBE_YML=./pod-and-containers.yaml
API_IMAGE=localhost/django-api

print-%  : ; @echo $($*)


################################################################################
# Dev container commands
################################################################################
build:
	$(COMPOSER) build --file $(CONTAINERFILE) --tag $(API_IMAGE) --label org.opencontainers.image.created=$(DATE) --label org.opencontainers.image.revision=$(GIT_REVISION) $(args)

up:
	-$(COMPOSER) play kube $(KUBE_YML)

down:
	$(COMPOSER) play kube --down $(KUBE_YML)

logs:
	$(COMPOSER) pod logs -f $(IMOBANCO_POD_NAME)

logs.django:
	$(COMPOSER) pod logs -f -c $(DJANGO_SERVICE_NAME) $(IMOBANCO_POD_NAME)

logs.psql:
	$(COMPOSER) pod logs -f -c $(PSQL_SERVICE_NAME) $(IMOBANCO_POD_NAME)

up.logs: up logs

bash:
	$(COMPOSER) exec --interactive=true --tty=true $(DJANGO_SERVICE_NAME) bash

bash.psql:
	$(COMPOSER) exec --interactive=true --tty=true $(PSQL_SERVICE_NAME) bash

test: up
	$(COMPOSER) exec --interactive=true --tty=true $(DJANGO_SERVICE_NAME) python manage.py test $(args)

shell:
	$(COMPOSER) exec --interactive=true --tty=true $(DJANGO_SERVICE_NAME) python manage.py shell $(args)

makemigrations:
	$(COMPOSER) exec --interactive=true --tty=true $(DJANGO_SERVICE_NAME) python manage.py makemigrations $(args)

migrate:
	$(COMPOSER) exec --interactive=true --tty=true $(DJANGO_SERVICE_NAME) python manage.py migrate $(args)

stop.django:
	$(COMPOSER) stop $(DJANGO_SERVICE_NAME)

podman.infos:
	$(COMPOSER) pod ls
	$(COMPOSER) ps --all
	$(COMPOSER) pod ps
	$(COMPOSER) volume ls

psql.ping:
	$(COMPOSER) exec $(PSQL_SERVICE_NAME) bash -c "pg_isready"


################################################################################
# Bare host commands
################################################################################
poetry.install:
	poetry config virtualenvs.in-project true
	poetry config virtualenvs.path .
	poetry install

fmt:
	isort .
	black .
	make fmt.check

fmt.check:
	isort --check-only .
	black --check .
	flake8
