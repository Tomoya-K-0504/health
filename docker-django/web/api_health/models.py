from django.db import models


class DataSource(models.Model):
    name = models.CharField(max_length=200)


class Acceleration(models.Model):
    data_source = models.ForeignKey(DataSource, on_delete=models.CASCADE)
    x = models.FloatField(default=0.0)
    y = models.FloatField(default=0.0)
    z = models.FloatField(default=0.0)

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


class EnvSensor(models.Model):
    data_source = models.ForeignKey(DataSource, on_delete=models.CASCADE)
    brightness = models.FloatField(default=0.0)
    m_peak_power = models.FloatField(default=0.0)
    m_average_power = models.FloatField(default=0.0)


class ActSensor(models.Model):
    data_source = models.ForeignKey(DataSource, on_delete=models.CASCADE)
    latitude = models.FloatField(default=0.0)
    longitude = models.FloatField(default=0.0)
    altitude = models.FloatField(default=0.0)


class Label(models.Model):
    name = models.CharField(max_length=100)


# class FitbitSleep(models.Model):
