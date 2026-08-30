import os
import time
from datetime import datetime, timezone
from typing import List, Dict, Any

import pymysql
from pymongo import MongoClient, ASCENDING
from pymongo.errors import DuplicateKeyError, PyMongoError
from pymysql.cursors import DictCursor

MYSQL_HOST = os.environ.get("MYSQL_HOST", "mysql")
MYSQL_PORT = int(os.environ.get("MYSQL_PORT", "3306"))
MYSQL_DB = os.environ.get("MYSQL_DB", "eventsdb")
MYSQL_USER = os.environ.get("MYSQL_USER", "app")
MYSQL_PASSWORD = os.environ.get("MYSQL_PASSWORD", "app")
MONGO_URI = os.environ.get("MONGO_URI", "mongodb://mongos:27017/logsdb")

BATCH_SIZE = int(os.environ.get("BATCH_SIZE", "100"))
SLEEP_SECONDS = int(os.environ.get("SLEEP_SECONDS", "5"))


def mysql_conn():
    return pymysql.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        database=MYSQL_DB,
        autocommit=True,
        cursorclass=DictCursor,
        charset="utf8mb4",
    )


def mongo_client():
    return MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)


def fetch_unprocessed(conn) -> List[Dict[str, Any]]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, registration_id, username, event_id, event_name, action, created_at
            FROM audit_logs
            WHERE processed = 0
            ORDER BY id
            LIMIT %s
            """,
            (BATCH_SIZE,),
        )
        return list(cur.fetchall())


def mark_processed(conn, log_id: int) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE audit_logs
            SET processed = 1, processed_at = NOW()
            WHERE id = %s
            """,
            (log_id,),
        )


def main():
    while True:
        try:
            client = mongo_client()
            db = client.get_default_database()
            collection = db.audit_logs
            collection.create_index([("source_log_id", ASCENDING)], unique=True)

            with mysql_conn() as conn:
                rows = fetch_unprocessed(conn)
                if not rows:
                    time.sleep(SLEEP_SECONDS)
                    continue

                for row in rows:
                    doc = {
                        "source_log_id": row["id"],
                        "registration_id": row["registration_id"],
                        "username": row["username"],
                        "event_id": row["event_id"],
                        "event_name": row["event_name"],
                        "action": row["action"],
                        "created_at": row["created_at"],
                        "ingested_at": datetime.now(timezone.utc),
                    }

                    try:
                        collection.insert_one(doc)
                    except DuplicateKeyError:
                        pass

                    mark_processed(conn, row["id"])

            client.close()
        except (PyMongoError, OSError, pymysql.MySQLError) as exc:
            print(f"[etl] problem techniczny: {exc}")
            time.sleep(SLEEP_SECONDS)
        except Exception as exc:
            print(f"[etl] nieoczekiwany błąd: {exc}")
            time.sleep(SLEEP_SECONDS)


if __name__ == "__main__":
    main()
