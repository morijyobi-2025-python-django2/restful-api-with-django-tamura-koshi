from rest_framework import viewsets
from .models import Syllabus
from .serializers import SyllabusSerializer

class SyllabusViewSet(viewsets.ModelViewSet):
    """
    シラバスのAPI (一覧, 作成, 取得, 更新, 削除)
    """
    queryset = Syllabus.objects.all() # どのデータを使うか (Syllabusの全データ)
    serializer_class = SyllabusSerializer # どの翻訳機(Serializer)を使うか
