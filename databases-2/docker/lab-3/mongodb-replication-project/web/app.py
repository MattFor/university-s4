from flask import Flask, request

import pymysql
import time

app = Flask(__name__)

PASSWORD = "tajnehaslo"

def get_connection():
    while True:
        try:
            return pymysql.connect(
                host="mysql-db",
                user="root",
                password="root",
                database="events_db"
            )
        except:
            time.sleep(2)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        password = request.form["password"]
        username = request.form["username"]
        event_name = request.form["event"]

        if password != PASSWORD:
            return "Niepoprawne haslo"

        conn = get_connection()
        cur = conn.cursor()

        cur.execute(
            "INSERT INTO registrations(username, event_name) VALUES(%s, %s)",
            (username, event_name)
        )

        conn.commit()
        conn.close()

        return "Zapisano na wydarzenie"

    return '''
    <h1>Rejestracja</h1>

    <form method="POST">
        Login:<br>
        <input name="username"><br><br>

        Haslo:<br>
        <input name="password" type="password"><br><br>

        Wydarzenie:<br>
        <select name="event">
            <option>Konferencja AI</option>
            <option>Hackathon</option>
            <option>Warsztaty Docker</option>
        </select><br><br>

        <button type="submit">Zapisz</button>
    </form>
    '''

app.run(host="0.0.0.0", port=5000)
