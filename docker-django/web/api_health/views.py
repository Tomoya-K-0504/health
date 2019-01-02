import json

from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt

from .models import Acceleration, DataSource


def index(request):
    return HttpResponse("Let's discover human.")


@csrf_exempt
def save_accel(request):
    if request.method == "POST":
        accel_data = json.loads(request.body.decode("utf-8"))
        acceleration = Acceleration.create(accel_data)
    return HttpResponseRedirect(reverse('api:index'))
