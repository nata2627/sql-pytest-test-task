from datetime import datetime, timedelta, timezone

import psycopg
import pytest


def test_connection_and_simple_query(db_params):
    """Подключаемся к БД, выполняем select now() и проверяем, что пришло текущее время."""
    with psycopg.connect(**db_params) as conn:
        row = conn.execute("select now()").fetchone()

    assert row is not None, "запрос не вернул ни одной строки"
    db_now = row[0]
    assert isinstance(db_now, datetime)
    # время сервера должно быть близко к локальному, иначе результат подозрительный
    assert abs(datetime.now(timezone.utc) - db_now) < timedelta(minutes=5)


def test_wrong_password_is_rejected(db_params):
    """Негативная проверка: с неверным паролем подключение должно падать с ошибкой."""
    bad = {**db_params, "password": db_params["password"] + "_wrong"}
    with pytest.raises(psycopg.OperationalError):
        psycopg.connect(**bad)
