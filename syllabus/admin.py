from django.contrib import admin
from django.contrib import admin
from .models import Syllabus  # .models から Syllabus モデルをインポート

# Syllabus モデルを管理サイトに登録
admin.site.register(Syllabus)
# Register your models here.
