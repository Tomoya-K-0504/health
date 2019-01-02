import json

from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt

from .models import Acceleration, DataSource, EnvSensor, ActSensor


def index(request):
    return HttpResponse("Let's discover human.")


@csrf_exempt
def save_accel(request):
    if request.method == "POST":
        accel_data = json.loads(request.body.decode("utf-8"))
        Acceleration.create(accel_data)
    return HttpResponseRedirect(reverse('api:index'))


@csrf_exempt
def save_env(request):
    if request.method == "POST":
        env_data = json.loads(request.body.decode("utf-8"))
        for env in env_data:
            env_sensor = EnvSensor(
                data_source=DataSource.objects.get(name=env["data_source"]),
                brightness=env["values"]["brightness"],
                m_peak_power=envenv["values"]["m_peak_power"],
                m_average_power=envenv["values"]["m_average_power"]
            )
            env_sensor.save()
    return HttpResponseRedirect(reverse('api:index'))


@csrf_exempt
def save_act(request):
    if request.method == "POST":
        act_data = json.loads(request.body.decode("utf-8"))
        for act in env_data:
            act_sensor = ActSensor(
                data_source=DataSource.objects.get(name=act["data_source"]),
                brightness=act["values"]["brightness"],
                m_peak_power=act["values"]["m_peak_power"],
                m_average_power=act["values"]["m_average_power"]
            )
            env_sensor.save()
    return HttpResponseRedirect(reverse('api:index'))
