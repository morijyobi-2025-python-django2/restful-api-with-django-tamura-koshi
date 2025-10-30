"""
URL configuration for tutorial project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import include, path
from rest_framework import routers

from tutorial.quickstart import views

# 1. ルーターを作成
router = routers.DefaultRouter()
# 2. ViewSet をルーターに登録
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)

# 3. URLパターンを設定
urlpatterns = [
    # routerが自動生成したURL (e.g., /users/, /groups/) を読み込む
    path('', include(router.urls)),

    # DRFの「ログイン/ログアウト」機能（ブラウザブルAPI用）
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('admin/', admin.site.urls),
]
