from rest_framework import viewsets, permissions
from .models import Syllabus
from .serializers import SyllabusSerializer

class SyllabusViewSet(viewsets.ModelViewSet):
    queryset = Syllabus.objects.all()
    serializer_class = SyllabusSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    # 絞り込み (完全一致)
    filterset_fields = ['school_year', 'semester', 'course_type', 'teacher_name']
    
    # 全文検索 (あいまい検索)
    search_fields = ['title_ja', 'title_en', 'overview_ja', 'overview_en', 'teacher_name'] # <-- この行を追加
