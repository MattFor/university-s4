import time
import pymysql

from pymongo import MongoClient

def mysql_connection():
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

def mongo_connection():
    while True:
        try:
            client = MongoClient(
                "mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0"
            )
            return client
        except:
            time.sleep(2)

mysql_conn = mysql_connection()
mongo_client = mongo_connection()

mongo_db = mongo_client["logs_db"]
logs_collection = mongo_db["audit_logs"]

while True:
    cursor = mysql_conn.cursor()

    cursor.execute(
        "SELECT id, message, created_at FROM audit_logs WHERE processed = FALSE"
    )

    logs = cursor.fetchall()

    for log in logs:
        log_id, message, created_at = log

        logs_collection.insert_one({
            "mysql_id": log_id,
            "message": message,
            "created_at": str(created_at)
        })

        cursor.execute(
            "UPDATE audit_logs SET processed = TRUE WHERE id = %s",
            (log_id,)
        )

        mysql_conn.commit()

        print(f"Przeniesiono log {log_id}")

    time.sleep(5)
