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