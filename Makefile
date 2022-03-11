SHELL := /bin/sh


COMPOSER=podman
CONTAINERFILE=Containerfile
CURRENT_DIR=$(shell basename $(CURRENT_PWD))
CURRENT_PWD=$(shell pwd)
DATE:=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
DB_HOST=localhost
DB_PORT=5432
DJANGO_SERVICE_NAME=service-django
GIT_REVISION:=$(shell git rev-parse --short HEAD)
IMAGE_NAME=imobanco/$(PROJECT_NAME)
IMAGE_TAG=latest
IMOBANCO_POD_NAME=django-pod
API_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG)
PROJECT_NAME=django-api
PSQL_SERVICE_NAME=service-postgres
PSQL_VOLUME_NAME=$(CURRENT_DIR)_$(PSQL_SERVICE_NAME)_volume

print-%  : ; @echo $($*)


################################################################################
# Dev container commands
################################################################################
build:
	$(COMPOSER) build --file $(CONTAINERFILE) --tag $(API_IMAGE) --label org.opencontainers.image.created=$(DATE) --label org.opencontainers.image.revision=$(GIT_REVISION) $(args)


create.pod:
	-$(COMPOSER) \
	pod \
	create \
	--publish=8000:8000 \
	--publish=$(DB_PORT):$(DB_PORT) \
	--name=$(IMOBANCO_POD_NAME)

create.psql:
	test -d dumps || mkdir --mode=0755 dumps
	-$(COMPOSER) \
	run \
	--detach=true \
	--env=POSTGRES_USER=postgres \
	--env=POSTGRES_PASSWORD=postgres \
	--env=POSTGRES_DB=postgres \
	--name=$(PSQL_SERVICE_NAME) \
	--pod=$(IMOBANCO_POD_NAME) \
	--volume=$(PSQL_VOLUME_NAME):/var/lib/postgresql/data \
	--volume=$(CURRENT_PWD)/dumps:/dumps \
	docker.io/library/postgres:12.3-alpine

create.django:
	-$(COMPOSER) \
	run \
	--detach=true \
	--env=DEBUG=True \
	--env=ENV=dev \
	--env=DB_PORT=$(DB_PORT) \
	--name=$(DJANGO_SERVICE_NAME) \
	--pod=$(IMOBANCO_POD_NAME) \
	--tty=true \
	--workdir=/home/app_user \
	--volume="$(CURRENT_PWD)":/home/app_user \
	$(API_IMAGE) \
	bash -c 'sleep 10000'

# bash -c 'python manage.py migrate && python manage.py runserver 0.0.0.0:8000'


create: create.pod create.psql create.django

up: create
	$(COMPOSER) pod start $(IMOBANCO_POD_NAME)

down: stop rm

logs:
	$(COMPOSER) logs --follow=true --names $(RABBIT_SERVICE_NAME) $(DJANGO_SERVICE_NAME) $(PSQL_SERVICE_NAME) $(CELERY_SERVICE_NAME)

logs.celery:
	$(COMPOSER) logs --follow=true --names $(CELERY_SERVICE_NAME)

logs.django:
	$(COMPOSER) logs --follow=true --names $(DJANGO_SERVICE_NAME)

logs.django.tail:
	$(COMPOSER) logs --names $(DJANGO_SERVICE_NAME) | tail -n 5

logs.psql:
	$(COMPOSER) logs --follow=true --names $(PSQL_SERVICE_NAME)

logs.psql.tail:
	$(COMPOSER) logs --names $(PSQL_SERVICE_NAME) | tail -n 5

up.psql: create.pod create.psql start.psql

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


stop:
	$(COMPOSER) pod stop --ignore $(IMOBANCO_POD_NAME)

stop.django:
	$(COMPOSER) stop $(DJANGO_SERVICE_NAME)


rm:
	$(COMPOSER) pod rm --ignore $(args) $(IMOBANCO_POD_NAME)
	$(COMPOSER) rm --ignore $(args) $(DJANGO_SERVICE_NAME)
	$(COMPOSER) rm --ignore $(args) $(PSQL_SERVICE_NAME)


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




