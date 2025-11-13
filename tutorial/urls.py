from django.contrib import admin
from django.urls import include, path
from rest_framework import routers

from tutorial.quickstart import views
from syllabus import views as syllabus_views  # <-- 1. この行を追加

router = routers.DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)
router.register(r'syllabuses', syllabus_views.SyllabusViewSet)  # <-- 2. この行を追加

urlpatterns = [
    path('admin/', admin.site.urls),

    # routerが自動生成したURL (e.g., /users/, /groups/, /syllabuses/) を読み込む
    path('', include(router.urls)),

    # DRFの「ログイン/ログアウト」機能（ブラウザブルAPI用）
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
