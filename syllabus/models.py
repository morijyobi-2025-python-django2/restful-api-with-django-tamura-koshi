from django.db import models


class Syllabus(models.Model):
    """シラバスモデル"""
    
    INSTRUCTOR_TYPE_CHOICES = [
        ('専任教員', '専任教員'),
        ('実務教員', '実務教員'),
        ('非常勤講師', '非常勤講師'),
    ]
    
    ENROLLMENT_CHOICES = [
        ('必修', '必修'),
        ('必修選択', '必修選択'),
        ('選択', '選択'),
    ]
    
    SEMESTER_CHOICES = [
        ('前期', '前期'),
        ('後期', '後期'),
        ('通年', '通年'),
    ]
    
    # 基本情報
    subject_name = models.CharField(max_length=200, verbose_name='科目名')
    regulation_subject_name = models.CharField(max_length=200, verbose_name='学則科目名')
    teacher_name = models.CharField(max_length=100, verbose_name='担当教員')
    instructor_type = models.CharField(
        max_length=20,
        choices=INSTRUCTOR_TYPE_CHOICES,
        verbose_name='講師区分'
    )
    teaching_method = models.CharField(max_length=100, verbose_name='授業方法')
    num_sessions = models.IntegerField(verbose_name='授業コマ数')
    recommended_grade = models.CharField(max_length=50, verbose_name='推奨履修年次')
    enrollment_classification = models.CharField(
        max_length=20,
        choices=ENROLLMENT_CHOICES,
        verbose_name='履修分類'
    )
    academic_year = models.IntegerField(verbose_name='開講年度')
    semester = models.CharField(
        max_length=20,
        choices=SEMESTER_CHOICES,
        verbose_name='開講期間'
    )
    eligible_departments = models.JSONField(
        default=list,
        blank=True,
        verbose_name='履修可能学科'
    )
    
    # 授業内容
    course_overview = models.TextField(blank=True, default='', verbose_name='授業概要')
    learning_objectives = models.TextField(blank=True, default='', verbose_name='到達目標')
    grading_prerequisites = models.TextField(blank=True, default='', verbose_name='成績評価の前提条件')
    grading_criteria = models.TextField(blank=True, default='', verbose_name='成績評価基準')
    required_study_outside_class = models.TextField(blank=True, default='', verbose_name='授業外に必要な学習内容')
    textbook = models.TextField(blank=True, default='', verbose_name='教材')
    certification = models.TextField(blank=True, default='', verbose_name='検定')
    textbook_cost = models.TextField(blank=True, default='', verbose_name='教材費')
    certification_cost = models.TextField(blank=True, default='', verbose_name='検定費')
    notes = models.TextField(blank=True, default='', verbose_name='履修にあたっての留意点')
    remarks = models.TextField(blank=True, default='', verbose_name='備考')
    
    # 管理用フィールド
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='作成日時')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新日時')
    
    class Meta:
        db_table = 'syllabi'
        verbose_name = 'シラバス'
        verbose_name_plural = 'シラバス'
        ordering = ['-academic_year', 'subject_name']

    def __str__(self):
        return f"{self.subject_name} ({self.academic_year})"


class ClassSession(models.Model):
    """コマシラバス（各授業回の詳細）"""
    
    syllabus = models.ForeignKey(
        Syllabus,
        on_delete=models.CASCADE,
        related_name='class_sessions',
        verbose_name='シラバス'
    )
    order = models.IntegerField(verbose_name='授業の順番')
    num_sessions = models.IntegerField(verbose_name='コマ数')
    content = models.TextField(verbose_name='授業内容')
    
    class Meta:
        db_table = 'class_sessions'
        verbose_name = 'コマシラバス'
        verbose_name_plural = 'コマシラバス'
        ordering = ['order']
    
    def __str__(self):
        return f"{self.syllabus.subject_name} - 第{self.order}回"
