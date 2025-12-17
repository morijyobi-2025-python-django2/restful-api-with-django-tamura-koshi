from rest_framework import viewsets, permissions
from .models import Syllabus
from .serializers import SyllabusSerializer


class SyllabusViewSet(viewsets.ModelViewSet):
    """
    シラバスのCRUD操作を提供するViewSet
    
    list: GET /api/syllabi/ - シラバス一覧取得
    create: POST /api/syllabi/ - シラバス作成 (認証必要)
    retrieve: GET /api/syllabi/{id}/ - シラバス詳細取得
    update: PUT /api/syllabi/{id}/ - シラバス更新 (認証必要)
    partial_update: PATCH /api/syllabi/{id}/ - シラバス部分更新 (認証必要)
    destroy: DELETE /api/syllabi/{id}/ - シラバス削除 (認証必要)
    """
    queryset = Syllabus.objects.all().prefetch_related('class_sessions')
    serializer_class = SyllabusSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    # フィルタリング (完全一致)
    filterset_fields = ['academic_year', 'semester', 'instructor_type', 
                        'teacher_name', 'enrollment_classification']
    
    # 検索 (部分一致)
    search_fields = ['subject_name', 'regulation_subject_name', 
                     'teacher_name', 'course_overview', 'learning_objectives']
