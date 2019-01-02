from django.db import models


class DataSource(models.Model):
    name = models.CharField(max_length=200)


class Acceleration(models.Model):
    data_source = models.ForeignKey(DataSource, on_delete=models.CASCADE)
    x = models.FloatField(default=0)
    y = models.FloatField(default=0)
    z = models.FloatField(default=0)

    @classmethod
    def create(cls, data_source, accel_dict):
        acceleration = Acceleration(data_source=data_source, x=accel_dict["x"], y=accel_dict["y"], z=accel_dict["z"])
        acceleration.save()
