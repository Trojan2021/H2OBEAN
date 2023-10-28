import sqlite3
from marker import Marker

#define connection and cursor

connection = sqlite3.connect('Markers.db')

cursor = connection.cursor()

# create stores tables

command1 = """CREATE TABLE IF NOT EXISTS marker(
            ppmValue REAL PRIMARY KEY,
            longitude real,
            latitude real,
            markerID text
            )"""
cursor.execute(command1)

def insertMarker(marker):
    with connection:
        cursor.execute("INSERT INTO marker VALUES (:ppmValue, :long, :lat, :id)", {'ppmValue':marker.ppmValue, 'long': marker.long, 'lat': marker.lat, 'id': marker.id})
        
def getMarkerByID(id):
    cursor.execute("SELECT * FROM marker WHERE markerID= :id", {'id': id})
    return cursor.fetchall()

def updatePPMValue(marker, ppmValue):
    with connection:
        cursor.exectue("""UPDATE marker SET ppmValue = :ppmValue 
                       WHERE long = :long AND lat = :lat AND id = :id""", 
                       {'ppmValue': marker.ppmValue, 'long': marker.long, 'id': marker.id})
        
def deleteMarker(marker):
    with connection:
        cursor.exectue("DELETE from employess WHERE id = :id", {'id': id})
    
marker1 = Marker(100, 33, 33, '24')
marker2 = Marker(120, 2, 5, '23')
insertMarker(marker1)
insertMarker(marker2)

printMarker = getMarkerByID('24')
printMarker1 = getMarkerByID('23')
print(printMarker)
print(printMarker1)
# cursor.execute("INSERT INTO marker VALUES (:ppmValue, :long, :lat, :id)", {'ppmValue':marker1.ppmValue, 'long': marker1.long, 'lat': marker1.lat, 'id': marker1.id})
# connection.commit()

# cursor.execute("SELECT * FROM marker WHERE markerID= :id", {'id': '24'})

# print(cursor.fetchone())
# connection.commit()

connection.close()

#IF NOT EXISTS
#stores(store_id INTEGER PRIMARY KEY, location TEXT)"""

# cursor.execute(command1)

# #create purchases table

# command2 = """CREATE TABLE IF NOT EXISTS 
# purchases(purchase_id INTEGER PRIMARY KEY, store_id INTEGER, total_cost FLOAT, 
# FOREIGN KEY(STORE_ID) REFERENCES stores(store_id))"""

# cursor.execute(command2)

# #add to stores

# cursor.execute("INSERT INTO stores VALUES (21, 'Minneapolis, MN')")
# cursor.execute("INSERT INTO stores VALUES (95, 'Chicago, IL')")
# cursor.execute("INSERT INTO stores VALUES (64, 'Iowa City, IA')")

# # add to purchases

# cursor.execute("INSERT INTO purchases VALUES (54, 21, 15.49)")
# cursor.execute("INSERT INTO purchases VALUES (23, 64, 21.12)")

# # get results

# cursor.execute("SELECT * FROM purchases")

# results = cursor.fetchall()
# print(results)