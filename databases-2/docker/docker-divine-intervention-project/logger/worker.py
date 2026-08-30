import os
import time
from datetime import datetime, timezone

import mysql.connector
from pymongo import MongoClient


MYSQL_CONFIG = {
    "host": "mysql",
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD"),
    "database": os.getenv("MYSQL_DATABASE"),
}

MONGO_URI = os.getenv("MONGO_URI")

MYSQL_HOST = "mysql"
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")

EVENT_NAMES = {
    1: "Chess Tournament",
    2: "Board Game Night",
    3: "Movie Marathon",
    4: "Cake Baking Contest",
    5: "FIFA Tournament",
    6: "General Knowledge Quiz",
    7: "Charity Run",
    8: "Family Picnic",
    9: "Talent Show",
    10: "Night Sky Watching",
}

def copy_lab2_data_to_mongo():
    log("Copying lab2.zadanie2 records to MongoDB")

    source_db = mysql.connector.connect(
        host=MYSQL_CONFIG["host"],
        user=MYSQL_CONFIG["user"],
        password=MYSQL_CONFIG["password"],
        database="lab2",
    )

    source_cur = source_db.cursor()

    mongo = wait_for_mongo()
    collection = mongo.lab2.zadanie2

    source_cur.execute("SELECT komunikat FROM zadanie2")

    for (komunikat,) in source_cur.fetchall():
        exists = collection.find_one({"komunikat": komunikat})

        if not exists:
            collection.insert_one({
                "komunikat": komunikat
            })

            log(f"Copied message: {komunikat}")
        else:
            log(f"Message already exists: {komunikat}")

    source_cur.close()
    source_db.close()

    log("Finished copying lab2.zadanie2")

def log(message: str) -> None:
    print(
        f"[INFO] {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')} UTC - {message}",
        flush=True,
    )


def warn(message: str) -> None:
    print(
        f"[WARN] {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')} UTC - {message}",
        flush=True,
    )


def error(message: str) -> None:
    print(
        f"[ERROR] {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')} UTC - {message}",
        flush=True,
    )


def mysql_connection():
    while True:
        try:
            log("Connecting to MySQL...")
            conn = mysql.connector.connect(**MYSQL_CONFIG)
            log("Connected to MySQL successfully")
            return conn
        except mysql.connector.Error as e:
            warn(f"Waiting for MySQL server: {e}")
            time.sleep(2)


def wait_for_mongo():
    while True:
        try:
            log("Connecting to MongoDB through mongos...")
            mongo = MongoClient(MONGO_URI)
            mongo.admin.command("ping")
            log("Connected to MongoDB successfully")
            return mongo
        except Exception as e:
            warn(f"Waiting for mongos router: {e}")
            time.sleep(2)


def main():
    mongo = wait_for_mongo()
    collection = mongo.logs.audit_logs

    log("Audit logger started")
    log("Reading unprocessed rows from MySQL audit_logs table")
    log("Forwarding documents to MongoDB")

    while True:
        db = mysql_connection()
        cur = db.cursor(dictionary=True)

        try:
            cur.execute(
                """
                SELECT id, operation_type, registration_id, event_id, created_at
                FROM audit_logs
                WHERE processed = FALSE
                ORDER BY id
                """
            )

            rows = cur.fetchall()

            if not rows:
                log("No new audit logs found")
            else:
                log(f"Found {len(rows)} unprocessed audit log(s)")

            for row in rows:
                event_id = int(row["event_id"])
                event_name = EVENT_NAMES.get(event_id, "Unknown event")

                log(
                    f"Processing audit_log_id={row['id']} "
                    f"event_id={event_id} "
                    f"event_name='{event_name}'"
                )

                document = {
                    "source": "mysql-trigger-audit_logs",
                    "operation": row["operation_type"],
                    "audit_log_id": int(row["id"]),
                    "registration_id": int(row["registration_id"]),
                    "event_id": event_id,
                    "event_name": event_name,
                    "mysql_log_created_at": str(row["created_at"]),
                    "mongo_logged_at": datetime.now(timezone.utc).isoformat(),
                }

                collection.insert_one(document)
                log(
                    f"Stored document in MongoDB "
                    f"(audit_log_id={row['id']}, event_id={event_id})"
                )

                cur.execute(
                    "UPDATE audit_logs SET processed = TRUE WHERE id = %s",
                    (row["id"],),
                )
                log(f"Marked audit_log_id={row['id']} as processed in MySQL")

            db.commit()
            log("MySQL transaction committed")

        except Exception as e:
            error(f"Logger error: {e}")
            try:
                db.rollback()
                warn("MySQL transaction rolled back")
            except Exception as rollback_error:
                warn(f"Rollback failed: {rollback_error}")

        finally:
            try:
                cur.close()
            except Exception:
                pass

            try:
                db.close()
            except Exception:
                pass

        log("Sleeping for 5 seconds before next poll")
        time.sleep(5)


if __name__ == "__main__":
    try:
        copy_lab2_data_to_mongo()
    except Exception as e:
        warn(f"Failed to copy lab2 data: {e}")

    while True:
        try:
            main()
        except Exception as e:
            error(f"Logger crashed: {e}")
            warn("Restarting in 5 seconds")
            time.sleep(5)
