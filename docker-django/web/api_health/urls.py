from django.urls import path
from . import views


app_name = 'api'
urlpatterns = [
    # ex: /polls/
    path('', views.index, name='index'),
    # ex: /polls/5/
    path('accel/', views.save_accel, name='save_accel'),
    path('env/', views.save_env, name='save_env'),
    path('act/', views.save_act, name='save_act'),
    # # ex: /polls/5/results/
    # path('<int:question_id>/results/', views.results, name='results'),
    # # ex: /polls/5/vote/
    # path('<int:question_id>/vote/', views.vote, name='vote'),
]
