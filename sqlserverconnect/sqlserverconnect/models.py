from django.db import models

class sqlserverconn(models.Model):
    CarId=models.IntegerField()
    CarType=models.CharField(max_length=100)
    CarModel=models.CharField(max_length=100)