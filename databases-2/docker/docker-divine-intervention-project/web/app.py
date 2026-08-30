import os
import time
import mysql.connector
from flask import Flask, request, render_template

app = Flask(__name__)

PASSWORD = os.getenv("FLASK_PASSWORD")

MYSQL_HOST = os.getenv("MYSQL_HOST", "mysql")
MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "events")
MYSQL_USER = os.getenv("MYSQL_USER", "user1")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")


def get_connection():
    while True:
        try:
            return mysql.connector.connect(
                host=MYSQL_HOST,
                user=MYSQL_USER,
                password=MYSQL_PASSWORD,
                database=MYSQL_DATABASE,
                autocommit=True
            )
        except mysql.connector.Error:
            time.sleep(2)


@app.route("/", methods=["GET", "POST"])
def index():
    message = ""

    if request.method == "POST":
        if request.form.get("password", "") != PASSWORD:
            return render_template(
                "index.html",
                message="Invalid password."
            )

        event_id = request.form.get("event", "")

        db = get_connection()
        cur = db.cursor()

        try:
            cur.execute(
                "INSERT INTO registrations(event_id) VALUES(%s)",
                (event_id,)
            )

            message = (
                "Registration saved successfully. "
                "The MySQL trigger created an audit log entry, "
                "and the worker will transfer it to the sharded MongoDB cluster."
            )
        finally:
            cur.close()
            db.close()

    return render_template(
        "index.html",
        message=message
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9001)
