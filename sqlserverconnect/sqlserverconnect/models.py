from pyexpat import model
from django.db import models

class sqlserverconn(models.Model):
    CarId=models.IntegerField()
    CarType=models.CharField(max_length=100)
    CarModel=models.CharField(max_length=100)

class insertData(models.Model):
    CustomerId=models.BigIntegerField()
    CustomerName=models.CharField(max_length=100)
    CustomerSurname=models.CharField(max_length=100)
    Mail=models.CharField(max_length=100)
    PhoneNumber=models.CharField(max_length=100)
    city=models.CharField(max_length=100)
    state=models.CharField(max_length=100)
    HESCode=models.CharField(max_length=100)
    Gender=models.CharField(max_length=100)
    BirthDate=models.DateTimeField()
    #Age=models.IntegerField()

class seeFlights(models.Model):
    FlightID=models.IntegerField()
    AirlineCompany=models.CharField(max_length=100)
    FlightDate=models.DateTimeField()
    FromAirport=models.CharField(max_length=100)
    toAirport=models.CharField(max_length=100)
    FlightTime=models.TimeField()

class seeHotels(models.Model):
    HotelID=models.IntegerField()
    HotelName=models.CharField(max_length=100)
    BuildingNo=models.PositiveSmallIntegerField()
    Street=models.CharField(max_length=100)
    City=models.CharField(max_length=100)
    Country=models.CharField(max_length=100)
