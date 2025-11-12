from django.contrib import admin  # <-- 1. この行を追加
from django.urls import include, path
from rest_framework import routers

from tutorial.quickstart import views

router = routers.DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),  # <-- 2. この行を追加
    
    # routerが自動生成したURL (e.g., /users/, /groups/) を読み込む
    path('', include(router.urls)),
    
    # DRFの「ログイン/ログアウト」機能（ブラウザブルAPI用）
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
