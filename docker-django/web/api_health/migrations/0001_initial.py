# Generated by Django 2.1.4 on 2019-01-02 01:08

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Acceleration',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('x_axis', models.FloatField(default=0)),
                ('y_axis', models.FloatField(default=0)),
                ('z_axis', models.FloatField(default=0)),
            ],
        ),
        migrations.CreateModel(
            name='DataSource',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
            ],
        ),
        migrations.AddField(
            model_name='acceleration',
            name='data_source',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='api_health.DataSource'),
        ),
    ]
