FROM python:3.8.3-slim-buster

# Set python environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 0
# ENV PIP_DISABLE_PIP_VERSION_CHECK 1

ENV USER app_user

WORKDIR /home/app_user

RUN addgroup app_group \
 && adduser \
    --quiet \
    --disabled-password \
    --shell /bin/bash \
    --home /home/app_user \
    --gecos "User" app_user \
    --ingroup app_group \
 && chmod 0700 /home/app_user \
 && chown --recursive app_user:app_group /home/app_user

COPY pyproject.toml poetry.lock /home/app_user

# Sobre a remoção do ~/.cache
# https://github.com/python-poetry/poetry/issues/3374#issuecomment-729558117
RUN python -m pip install --upgrade pip==21.2.2 \
 && pip install 'poetry==1.1.7' \
 && poetry config virtualenvs.create false \
 && poetry install --no-interaction --no-root \
 && rm -frv ~/.cache
