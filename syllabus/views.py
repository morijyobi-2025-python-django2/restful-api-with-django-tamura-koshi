from rest_framework import viewsets
from rest_framework import permissions  # <-- 1. この行を追加
from .models import Syllabus
from .serializers import SyllabusSerializer

class SyllabusViewSet(viewsets.ModelViewSet):
    """
    シラバスのAPI (一覧, 作成, 取得, 更新, 削除)
    """
    queryset = Syllabus.objects.all()
    serializer_class = SyllabusSerializer

    # 権限設定を追加: 読み取りは誰でもOK, 書き込みは認証ユーザーのみ
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]  # <-- 2. この行を追加
