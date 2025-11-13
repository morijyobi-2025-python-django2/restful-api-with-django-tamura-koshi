from rest_framework import viewsets, permissions
from .models import Syllabus
from .serializers import SyllabusSerializer

class SyllabusViewSet(viewsets.ModelViewSet):
    queryset = Syllabus.objects.all()
    serializer_class = SyllabusSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    # 検索対象とするフィールドを指定
    filterset_fields = ['school_year', 'semester', 'course_type', 'teacher_name'] # <-- この行を追加
