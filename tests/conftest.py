import os

import pytest
from dotenv import load_dotenv

load_dotenv()


@pytest.fixture(scope="session")
def db_params():
    """Параметры подключения из переменных окружения (или файла .env)."""
    return {
        "host": os.getenv("DB_HOST", "localhost"),
        "port": int(os.getenv("DB_PORT", "5432")),
        "dbname": os.getenv("DB_NAME", "modul_test"),
        "user": os.getenv("DB_USER", "modul_test"),
        "password": os.getenv("DB_PASSWORD", ""),
        "connect_timeout": 5,
    }
