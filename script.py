import sqlite3
from marker import Marker
from flask import Flask, jsonify, request
from flask_cors import CORS
from watersensor import getAverage

app = Flask(__name__)
CORS(app)


def get_db_connection():
    conn = sqlite3.connect("Markers.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    command1 = """CREATE TABLE IF NOT EXISTS marker(
            ppmValue integer,
            long real,
            lat real
            )"""
    cursor.execute(command1)
    return conn


@app.route("/getnew", methods=["GET", "POST"])
def getNewMarkers():
    global markerTotal
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM marker")
    printMarkerList = cursor.fetchall()
    marker_list = []
    for row in printMarkerList:
        marker_dict = {
            "ppmValue": row[0],
            "lat": row[1],
            "long": row[2],
        }
        marker_list.append(marker_dict)
    conn.close()
    return jsonify(marker_list)


@app.route("/endpoint", methods=["POST"])
def receive_data():
    conn = get_db_connection()
    cursor = conn.cursor()
    data = request.form.get("data")
    latlng = data.split(",")
    marker = Marker(getAverage(), float(latlng[0]), float(latlng[1]))
    with conn:
        cursor.execute(
            "INSERT INTO marker VALUES (:ppmValue, :long, :lat)",
            {
                "ppmValue": marker.ppmValue,
                "long": marker.long,
                "lat": marker.lat,
            },
        )
    conn.close()
    return "Data received test!", 200


@app.route("/deletemarker", methods=["GET", "POST"])
def deleteMarker():
    conn = get_db_connection()
    cursor = conn.cursor()
    data = request.form.get("data")
    latitude = float(data)
    cursor.execute("DELETE from marker") #WHERE lat = :lat", {"lat": latitude})
    conn.commit()
    conn.close()
    return "Data received test!", 200


if __name__ == "__main__":
    app.run(debug=True)
