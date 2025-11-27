from django.db import models

class Syllabus(models.Model):
    """
    シラバスのモデル
    """
    # (openapi.yaml に合わせたフィールド定義)
    title_ja = models.CharField(max_length=100)
    title_en = models.CharField(max_length=100, blank=True)
    teacher_name = models.CharField(max_length=100)
    school_year = models.IntegerField()
    semester = models.CharField(max_length=20)
    num_credits = models.IntegerField()
    target_grade = models.CharField(max_length=20)
    course_type = models.CharField(max_length=50)

    overview_ja = models.TextField(blank=True)
    overview_en = models.TextField(blank=True)
    prerequisites_ja = models.TextField(blank=True)
    prerequisites_en = models.TextField(blank=True)

    textbook = models.TextField(blank=True)
    reference_book = models.TextField(blank=True)

    grading_policy_ja = models.TextField(blank=True)
    grading_policy_en = models.TextField(blank=True)

    notes_ja = models.TextField(blank=True)
    notes_en = models.TextField(blank=True)

    # (自動設定されるフィールド)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title_ja
