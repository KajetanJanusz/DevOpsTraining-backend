ARG PYTHON_VERSION=3.12.2
ARG POETRY_VERSION=1.8.2

FROM python:${PYTHON_VERSION}-slim-bookworm as python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=${POETRY_VERSION} \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        postgresql-client \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


FROM python-base AS builder-base

# ustawic jedną wersję poetry
RUN curl -sSL https://install.python-poetry.org | python -

WORKDIR $PYSETUP_PATH

COPY ./poetry/poetry.lock ./poetry/pyproject.toml ./

RUN poetry install --no-dev --no-root


FROM python-base as development

ENV DJANGO_ENV=development

WORKDIR $PYSETUP_PATH
COPY --from=builder-base $POETRY_HOME $POETRY_HOME
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

RUN poetry install

RUN addgroup --gid 1001 --system app && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app
USER app

WORKDIR /app
COPY --chown=app:app . .

RUN chmod +x ./core/docker_entrypoints/run_backend.sh

ENTRYPOINT [ "./core/docker_entrypoints/run_backend.sh" ]


FROM python-base as production

ENV DJANGO_ENV=production

WORKDIR $PYSETUP_PATH
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

RUN addgroup --gid 1001 --system app && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app
USER app

WORKDIR /app
COPY --chown=app:app . .

RUN chmod +x ./core/docker_entrypoints/run_backend.sh

ENTRYPOINT [ "./core/docker_entrypoints/run_backend.sh" ]
