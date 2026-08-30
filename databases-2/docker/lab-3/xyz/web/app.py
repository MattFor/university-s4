import os
from typing import Dict

import pymysql
from flask import Flask, Response, request
from pymysql.cursors import DictCursor

app = Flask(__name__)

MYSQL_HOST = os.environ.get("MYSQL_HOST", "mysql")
MYSQL_PORT = int(os.environ.get("MYSQL_PORT", "3306"))
MYSQL_DB = os.environ.get("MYSQL_DB", "eventsdb")
MYSQL_USER = os.environ.get("MYSQL_USER", "root")
MYSQL_PASSWORD = os.environ.get("MYSQL_PASSWORD", "root")
ACCESS_PASSWORD = os.environ.get("ACCESS_PASSWORD", "secret123")

EVENTS: Dict[int, str] = {
    1: "Wydarzenie 1",
    2: "Wydarzenie 2",
    3: "Wydarzenie 3",
}


import time

def get_conn():
    last_error = None

    for attempt in range(30):
        try:
            print(f"Connecting to MySQL attempt {attempt + 1}")

            conn = pymysql.connect(
                host=MYSQL_HOST,
                port=MYSQL_PORT,
                user=MYSQL_USER,
                password=MYSQL_PASSWORD,
                database=MYSQL_DB,
                autocommit=False,
                cursorclass=DictCursor,
                charset="utf8mb4",
                connect_timeout=10,
                read_timeout=10,
                write_timeout=10,
            )

            print("Connected to MySQL")
            return conn

        except Exception as exc:
            last_error = exc
            print(f"MySQL not ready yet: {exc}")
            time.sleep(2)

    raise last_error


HTML = """
<!doctype html>
<html lang="pl">
<head>
  <meta charset="utf-8">
  <title>Rejestracja na wydarzenie</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 720px; margin: 40px auto; line-height: 1.5; }
    label { display: block; margin-top: 12px; }
    input, select, button { width: 100%; padding: 10px; margin-top: 6px; box-sizing: border-box; }
    .box { border: 1px solid #ccc; padding: 20px; border-radius: 12px; }
    .hint { color: #666; font-size: 0.95rem; }
    .ok { color: #0a7a0a; }
    .err { color: #b00020; }
  </style>
</head>
<body>
  <h1>Rejestracja na wydarzenie</h1>
  <div class="box">
    <form method="post" action="/register">
      <label>Hasło dostępu
        <input name="password" type="password" required>
      </label>

      <label>Nazwa użytkownika
        <input name="username" type="text" required>
      </label>

      <label>Wydarzenie
        <select name="event_id" required>
          <option value="1">Wydarzenie 1</option>
          <option value="2">Wydarzenie 2</option>
          <option value="3">Wydarzenie 3</option>
        </select>
      </label>

      <button type="submit">Zapisz się</button>
    </form>

    <p class="hint">
      Po zapisie trigger MySQL zapisuje log do tabeli audit_logs, a serwis ETL przenosi go do MongoDB.
    </p>
  </div>
</body>
</html>
"""


@app.get("/")
def index():
    return Response(HTML, mimetype="text/html; charset=utf-8")


@app.get("/health")
def health():
    try:
        conn = get_conn()
        with conn.cursor() as cur:
            cur.execute("SELECT 1 AS ok")
            result = cur.fetchone()
        conn.close()
        if result and result.get("ok") == 1:
            return Response("OK", status=200, mimetype="text/plain; charset=utf-8")
        return Response("DB check failed", status=500, mimetype="text/plain; charset=utf-8")
    except Exception as exc:
        return Response(f"Health check error: {exc}", status=500, mimetype="text/plain; charset=utf-8")


@app.post("/register")
def register():
    password = request.form.get("password", "").strip()
    if password != ACCESS_PASSWORD:
        return Response("Błędne hasło.", status=403, mimetype="text/plain; charset=utf-8")

    username = request.form.get("username", "").strip()
    event_id_raw = request.form.get("event_id", "").strip()

    if not username:
        return Response("Brak nazwy użytkownika.", status=400, mimetype="text/plain; charset=utf-8")

    try:
        event_id = int(event_id_raw)
    except ValueError:
        return Response("Nieprawidłowy identyfikator wydarzenia.", status=400, mimetype="text/plain; charset=utf-8")

    event_name = EVENTS.get(event_id)
    if event_name is None:
        return Response("Nieznane wydarzenie.", status=400, mimetype="text/plain; charset=utf-8")

    conn = None
    try:
        conn = get_conn()
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO registrations (username, event_id, event_name)
                VALUES (%s, %s, %s)
                """,
                (username, event_id, event_name),
            )
        conn.commit()

        return Response(
            f"Zapisano użytkownika {username} na {event_name}.",
            mimetype="text/plain; charset=utf-8",
        )

    except Exception as exc:
        if conn is not None:
            conn.rollback()
        return Response(f"Błąd bazy danych: {exc}", status=500, mimetype="text/plain; charset=utf-8")

    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
