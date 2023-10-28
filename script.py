import sqlite3
from marker import Marker

#define connection and cursor

connection = sqlite3.connect(':memory:')#('Markers.db')

cursor = connection.cursor()

markerTotal = 0

# create stores tables

command1 = """CREATE TABLE IF NOT EXISTS marker(
            ppmValue real,
            long real,
            lat real,
            id text PRIMARY KEY
            )"""
cursor.execute(command1)

def insertMarker(marker):
    global markerTotal
    markerTotal += 1
    with connection:
        cursor.execute("INSERT INTO marker VALUES (:ppmValue, :long, :lat, :id)", {'ppmValue':marker.ppmValue, 'long': marker.long, 'lat': marker.lat, 'id': marker.id})
        
def getMarkerByID(id):
    cursor.execute("SELECT * FROM marker WHERE id= :id", {'id': id})
    return cursor.fetchall()

def updatePPMValue(marker, ppmValue):
    with connection:
        cursor.execute("""UPDATE marker SET ppmValue = :ppmValue 
                       WHERE long = :long AND lat = :lat AND id = :id""", 
                       {'ppmValue': marker.ppmValue, 'long': marker.long, 'id': marker.id})
        
def deleteMarker(marker):
    global markerTotal
    markerTotal -= 1
    with connection:
        cursor.execute("DELETE from marker WHERE id = :id", {'id': marker.id})
    
marker1 = Marker(100, 33, 33, '24')
marker2 = Marker(120, 2, 5, '23')
insertMarker(marker1)
insertMarker(marker2)

printMarker = getMarkerByID('24')
printMarker1 = getMarkerByID('23')
print(printMarker)
print(printMarker1)
deleteMarker(marker1)
print(markerTotal)
deleteMarker(marker2)

connection.close()
