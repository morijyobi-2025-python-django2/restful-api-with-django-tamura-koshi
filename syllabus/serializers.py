from rest_framework import serializers
from .models import Syllabus, ClassSession


class ClassSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClassSession
        fields = ['id', 'order', 'num_sessions', 'content']
        read_only_fields = ['id']


class SyllabusSerializer(serializers.ModelSerializer):
    class_sessions = ClassSessionSerializer(many=True, read_only=True)
    
    class Meta:
        model = Syllabus
        fields = [
            'id', 'subject_name', 'regulation_subject_name',
            'teacher_name', 'instructor_type', 'teaching_method',
            'num_sessions', 'recommended_grade', 'enrollment_classification',
            'academic_year', 'semester', 'eligible_departments',
            'course_overview', 'learning_objectives',
            'grading_prerequisites', 'grading_criteria',
            'required_study_outside_class', 'textbook',
            'certification', 'textbook_cost', 'certification_cost',
            'notes', 'remarks', 'class_sessions',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
