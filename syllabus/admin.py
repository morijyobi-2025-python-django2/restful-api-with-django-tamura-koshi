from django.contrib import admin
from .models import Syllabus, ClassSession


class ClassSessionInline(admin.TabularInline):
    model = ClassSession
    extra = 1
    fields = ['order', 'num_sessions', 'content']


@admin.register(Syllabus)
class SyllabusAdmin(admin.ModelAdmin):
    list_display = ['id', 'subject_name', 'teacher_name', 
                    'academic_year', 'semester', 'num_sessions']
    list_filter = ['academic_year', 'semester', 'instructor_type', 
                   'enrollment_classification']
    search_fields = ['subject_name', 'regulation_subject_name', 'teacher_name']
    inlines = [ClassSessionInline]
    
    fieldsets = (
        ('基本情報', {
            'fields': ('subject_name', 'regulation_subject_name')
        }),
        ('教員情報', {
            'fields': ('teacher_name', 'instructor_type')
        }),
        ('授業情報', {
            'fields': ('teaching_method', 'num_sessions', 'recommended_grade',
                      'enrollment_classification', 'academic_year', 'semester',
                      'eligible_departments')
        }),
        ('授業内容', {
            'fields': ('course_overview', 'learning_objectives')
        }),
        ('評価基準', {
            'fields': ('grading_prerequisites', 'grading_criteria')
        }),
        ('その他', {
            'fields': ('required_study_outside_class', 'textbook', 'certification',
                      'textbook_cost', 'certification_cost', 'notes', 'remarks'),
            'classes': ('collapse',)
        }),
    )


@admin.register(ClassSession)
class ClassSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'syllabus', 'order', 'num_sessions']
    list_filter = ['syllabus']
    ordering = ['syllabus', 'order']
