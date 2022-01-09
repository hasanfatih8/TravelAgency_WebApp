from django.shortcuts import render
from sqlserverconnect.models import sqlserverconn
from sqlserverconnect.models import insertData
import pyodbc

# def connsql(request):
#     conn=pyodbc.connect('Driver={sql server};'
#                         'Server=HASANFATIH8;'
#                         'Database=TravelAgency;'
#                         'Trusted_Connection=yes;')
#     cursor=conn.cursor()
#     cursor.execute("select * from Car")
#     result=cursor.fetchall()
#     return render(request, 'Index.html', {'sqlserverconn':result})

def insertCustomer(request):
    conn=pyodbc.connect('Driver={sql server};'
                        'Server=HASANFATIH8;'
                        'Database=TravelAgency;'
                        'Trusted_Connection=yes;')
    if request.method=="POST":
        if (request.POST.get('CustomerId') and request.POST.get('CustomerName') and request.POST.get('CustomerSurname') and 
            request.POST.get('Mail') and request.POST.get('PhoneNumber') and request.POST.get('city') and 
            request.POST.get('state') and request.POST.get('HESCode') and request.POST.get('Gender') and
            request.POST.get('BirthDate')):
            insertValues=insertData()
            insertValues.CustomerId=request.POST.get('CustomerId')
            insertValues.CustomerNameme=request.POST.get('CustomerName')
            insertValues.CustomerSurname=request.POST.get('CustomerSurname')
            insertValues.Mail=request.POST.get('Mail')
            insertValues.PhoneNumber=request.POST.get('PhoneNumber')
            insertValues.city=request.POST.get('city')
            insertValues.state=request.POST.get('state')
            insertValues.HESCode=request.POST.get('HESCode')
            insertValues.Gender=request.POST.get('Gender')
            insertValues.BirthDate=request.POST.get('BirthDate')
            cursor=conn.cursor()
            cursor.execute("insert into Customer values ('"+insertValues.CustomerId+"','"+insertValues.CustomerName+"','"+insertValues.CustomerSurname+"','"+insertValues.Mail+"','"+insertValues.PhoneNumber+"','"+insertValues.city+"','"+insertValues.state+"','"+insertValues.HESCode+"','"+insertValues.Gender+"','"+insertValues.BirthDate+"')")
            #insertValues.Age=request.POST.get('')
            cursor.commit()
            return render(request, 'Index.html')
    else:
        return render(request, 'Index.html')