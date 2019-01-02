from django.db import models


class DataSource(models.Model):
    name = models.CharField(max_length=200)


class Acceleration(models.Model):
    data_source = models.ForeignKey(DataSource, on_delete=models.CASCADE)
    x = models.FloatField(default=0)
    y = models.FloatField(default=0)
    z = models.FloatField(default=0)

    @classmethod
    def create(cls, accel_data):
        for accel_dict in accel_data:
            data_source = DataSource.objects.get(name=accel_dict["data_source"])
            acceleration = Acceleration(
                data_source=data_source,
                x=accel_dict["values"]["x"],
                y=accel_dict["values"]["y"],
                z=accel_dict["values"]["z"]
            )
        # acceleration.save()
