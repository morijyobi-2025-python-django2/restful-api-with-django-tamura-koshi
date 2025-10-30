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
]
