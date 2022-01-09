from django.shortcuts import render
from sqlserverconnect.models import sqlserverconn
import pyodbc

def connsql(request):
    conn=pyodbc.connect('Driver={sql server};'
                        'Server=HASANFATIH8;'
                        'Database=TravelAgency;'
                        'Trusted_Connection=yes;')
    cursor=conn.cursor()
    cursor.execute("select * from Car")
    result=cursor.fetchall()
    return render(request, 'Index.html', {'sqlserverconn':result})