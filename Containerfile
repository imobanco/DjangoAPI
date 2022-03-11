FROM python:3.8.3-slim-buster

# Set python environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 0
# ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# COPY pyproject.toml poetry.lock /home/app_user

# # Sobre a remoção do ~/.cache
# # https://github.com/python-poetry/poetry/issues/3374#issuecomment-729558117
# RUN python -m pip install --upgrade pip==21.2.2 \
#  && pip install 'poetry==1.1.7' \
#  && poetry config virtualenvs.create false \
#  && poetry install --no-interaction --no-root \
#  && rm -frv ~/.cache
