import pyodbc 

conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=HASANFATIH8;'
                      'Database=TravelAgency;'
                      'Trusted_Connection=yes;')

cursor = conn.cursor()
cursor.execute('SELECT * FROM Customer')

for i in cursor:
    print(i)