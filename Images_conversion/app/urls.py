from django.urls import re_path, path
from .views import ConvertImageView

urlpatterns = [
    path('convert-image/',
         ConvertImageView.as_view(), name = 'convert-image')
]
