FROM python:3.10-slim
ENV PYTHONUNBUFFERED=1

WORKDIR /src

RUN pip install poetry

COPY ./pyproject.toml ./poetry.lock* ./

RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root --only main

ENTRYPOINT ["poetry", "run", "python", "main.py"]

