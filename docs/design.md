# シラバスAPI 実装設計書

## 1. プロジェクト概要

シラバス管理のためのRESTful APIを実装します。本APIは、教育機関におけるシラバス情報の登録、取得、更新、削除機能を提供します。

### 対象範囲
- シラバスの基本情報管理
- コマシラバス（授業スケジュール）の管理
- CRUD操作の完全実装

## 2. 技術スタック

### フレームワーク・ライブラリ
- **Django**: 5.2.7
- **Django REST framework**: 最新版
- **Python**: 3.14

### ツール
- **uv**: Pythonパッケージマネージャー
- **mise**: ランタイム管理ツール
- **SQLite3**: 開発用データベース

### API仕様
- **OpenAPI**: 3.0.3（openapi.yaml参照）

## 3. プロジェクト構造

```
restful-api-with-django-suzuryo/
├── manage.py
├── pyproject.toml
├── uv.lock
├── mise.toml
├── openapi.yaml
├── db.sqlite3
├── docs/
│   ├── design.md          # 本設計書
│   └── index.html         # API仕様書（自動生成）
├── tutorial/              # Djangoプロジェクト
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   ├── asgi.py
│   └── quickstart/        # 既存アプリ（削除または名称変更予定）
└── syllabus/              # 新規作成するアプリ
    ├── __init__.py
    ├── models.py          # データモデル
    ├── serializers.py     # シリアライザ
    ├── views.py           # ビュー
    ├── urls.py            # URLルーティング
    ├── admin.py           # 管理画面設定
    ├── tests.py           # テストコード
    ├── apps.py
    └── migrations/
```

## 4. データモデル設計

### 4.1 Syllabusモデル

シラバスの基本情報を管理するモデルです。

```python
from django.db import models

class Syllabus(models.Model):
    """シラバスモデル"""

    # 基本情報
    subject_name = models.CharField(
        max_length=255,
        verbose_name="科目名",
        help_text="例: Python応用(Django)②"
    )
    academic_subject_name = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        verbose_name="学則科目名",
        help_text="例: システム開発演習"
    )

    # 教員情報
    instructor = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name="担当教員"
    )

    INSTRUCTOR_TYPE_CHOICES = [
        ('実務教員', '実務教員'),
        ('専任教員', '専任教員'),
        ('非常勤講師', '非常勤講師'),
    ]
    instructor_type = models.CharField(
        max_length=20,
        choices=INSTRUCTOR_TYPE_CHOICES,
        blank=True,
        null=True,
        verbose_name="講師区分"
    )

    # 授業形態
    TEACHING_METHOD_CHOICES = [
        ('講義', '講義'),
        ('演習', '演習'),
        ('講義&演習', '講義&演習'),
        ('実習', '実習'),
    ]
    teaching_method = models.CharField(
        max_length=20,
        choices=TEACHING_METHOD_CHOICES,
        blank=True,
        null=True,
        verbose_name="授業方法"
    )

    class_hours = models.IntegerField(
        blank=True,
        null=True,
        verbose_name="授業コマ数"
    )

    # 履修情報
    recommended_year = models.CharField(
        max_length=50,
        blank=True,
        null=True,
        verbose_name="推奨履修年次",
        help_text="例: 2年～"
    )

    COURSE_CLASSIFICATION_CHOICES = [
        ('必修', '必修'),
        ('選択', '選択'),
        ('必修選択', '必修選択'),
    ]
    course_classification = models.CharField(
        max_length=20,
        choices=COURSE_CLASSIFICATION_CHOICES,
        blank=True,
        null=True,
        verbose_name="履修分類"
    )

    # 開講情報
    academic_year = models.IntegerField(
        verbose_name="開講年度",
        help_text="例: 2025"
    )

    SEMESTER_CHOICES = [
        ('前期', '前期'),
        ('後期', '後期'),
        ('通年', '通年'),
    ]
    semester = models.CharField(
        max_length=10,
        choices=SEMESTER_CHOICES,
        blank=True,
        null=True,
        verbose_name="開講期間"
    )

    # 対象学科（JSONFieldで配列を保存）
    eligible_departments = models.JSONField(
        default=list,
        blank=True,
        verbose_name="履修可能学科",
        help_text="例: ['高度情報工学科', '総合システム工学科']"
    )

    # 授業内容
    course_overview = models.TextField(
        blank=True,
        null=True,
        verbose_name="授業概要"
    )
    learning_objectives = models.TextField(
        blank=True,
        null=True,
        verbose_name="到達目標"
    )

    # 評価基準
    grading_prerequisites = models.TextField(
        blank=True,
        null=True,
        verbose_name="成績評価の前提条件"
    )
    grading_criteria = models.TextField(
        blank=True,
        null=True,
        verbose_name="成績評価基準"
    )

    # その他の情報
    self_study_required = models.TextField(
        blank=True,
        null=True,
        verbose_name="授業外に必要な学習内容"
    )
    textbook = models.TextField(
        blank=True,
        null=True,
        verbose_name="教材"
    )
    certification = models.TextField(
        blank=True,
        null=True,
        verbose_name="検定"
    )
    textbook_cost = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name="教材費"
    )
    certification_cost = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name="検定費"
    )
    notes = models.TextField(
        blank=True,
        null=True,
        verbose_name="履修にあたっての留意点"
    )
    remarks = models.TextField(
        blank=True,
        null=True,
        verbose_name="備考"
    )

    # 管理用フィールド
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="作成日時")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="更新日時")

    class Meta:
        db_table = 'syllabi'
        verbose_name = 'シラバス'
        verbose_name_plural = 'シラバス一覧'
        ordering = ['-academic_year', 'subject_name']

    def __str__(self):
        return f"{self.subject_name} ({self.academic_year})"
```

### 4.2 ClassScheduleモデル

コマシラバス（授業スケジュール）を管理するモデルです。

```python
class ClassSchedule(models.Model):
    """コマシラバスモデル"""

    syllabus = models.ForeignKey(
        Syllabus,
        on_delete=models.CASCADE,
        related_name='class_schedule',
        verbose_name="シラバス"
    )

    order = models.IntegerField(
        verbose_name="順番",
        help_text="授業の実施順序"
    )

    class_hours = models.IntegerField(
        verbose_name="コマ数",
        help_text="この項目に割り当てるコマ数"
    )

    content = models.TextField(
        verbose_name="内容",
        help_text="授業内容の説明"
    )

    # 管理用フィールド
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="作成日時")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="更新日時")

    class Meta:
        db_table = 'class_schedules'
        verbose_name = 'コマシラバス'
        verbose_name_plural = 'コマシラバス一覧'
        ordering = ['syllabus', 'order']
        # 同一シラバス内で順番が重複しないようにする
        unique_together = [['syllabus', 'order']]

    def __str__(self):
        return f"{self.syllabus.subject_name} - 第{self.order}回"
```

### 4.3 データモデルの特徴

1. **リレーション**: ClassScheduleはSyllabusに対してN:1の関係
2. **JSONField**: eligible_departmentsは配列データをJSONで保存
3. **Choices**: 固定値項目は選択肢として定義
4. **管理用フィールド**: created_at, updated_atで作成・更新日時を自動記録
5. **unique_together**: シラバス内で授業順序が重複しないように制約

## 5. シリアライザ設計

### 5.1 ClassScheduleSerializer

```python
from rest_framework import serializers
from .models import Syllabus, ClassSchedule

class ClassScheduleSerializer(serializers.ModelSerializer):
    """コマシラバス用シリアライザ（読み取り専用）"""

    class Meta:
        model = ClassSchedule
        fields = ['id', 'order', 'class_hours', 'content']
        read_only_fields = ['id']


class ClassScheduleCreateSerializer(serializers.ModelSerializer):
    """コマシラバス作成用シリアライザ"""

    class Meta:
        model = ClassSchedule
        fields = ['order', 'class_hours', 'content']

    def validate_class_hours(self, value):
        """コマ数の妥当性チェック"""
        if value <= 0:
            raise serializers.ValidationError("コマ数は1以上である必要があります")
        return value

    def validate_order(self, value):
        """順番の妥当性チェック"""
        if value <= 0:
            raise serializers.ValidationError("順番は1以上である必要があります")
        return value
```

### 5.2 SyllabusSerializer

```python
class SyllabusSerializer(serializers.ModelSerializer):
    """シラバス用シリアライザ（詳細表示用）"""

    class_schedule = ClassScheduleSerializer(many=True, read_only=True)

    class Meta:
        model = Syllabus
        fields = [
            'id', 'subject_name', 'academic_subject_name',
            'instructor', 'instructor_type', 'teaching_method',
            'class_hours', 'recommended_year', 'course_classification',
            'academic_year', 'semester', 'eligible_departments',
            'course_overview', 'learning_objectives',
            'grading_prerequisites', 'grading_criteria',
            'self_study_required', 'textbook', 'certification',
            'textbook_cost', 'certification_cost', 'notes', 'remarks',
            'class_schedule'
        ]
        read_only_fields = ['id']


class SyllabusCreateSerializer(serializers.ModelSerializer):
    """シラバス作成・更新用シリアライザ"""

    class_schedule = ClassScheduleCreateSerializer(many=True, required=False)

    class Meta:
        model = Syllabus
        fields = [
            'subject_name', 'academic_subject_name',
            'instructor', 'instructor_type', 'teaching_method',
            'class_hours', 'recommended_year', 'course_classification',
            'academic_year', 'semester', 'eligible_departments',
            'course_overview', 'learning_objectives',
            'grading_prerequisites', 'grading_criteria',
            'self_study_required', 'textbook', 'certification',
            'textbook_cost', 'certification_cost', 'notes', 'remarks',
            'class_schedule'
        ]

    def validate_academic_year(self, value):
        """開講年度の妥当性チェック"""
        if value < 2000 or value > 2100:
            raise serializers.ValidationError("開講年度は2000～2100の範囲で指定してください")
        return value

    def create(self, validated_data):
        """シラバスとコマシラバスを同時に作成"""
        class_schedule_data = validated_data.pop('class_schedule', [])
        syllabus = Syllabus.objects.create(**validated_data)

        for schedule_data in class_schedule_data:
            ClassSchedule.objects.create(syllabus=syllabus, **schedule_data)

        return syllabus

    def update(self, instance, validated_data):
        """シラバスとコマシラバスを同時に更新"""
        class_schedule_data = validated_data.pop('class_schedule', None)

        # シラバス本体を更新
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # コマシラバスが指定されている場合は全削除して再作成
        if class_schedule_data is not None:
            instance.class_schedule.all().delete()
            for schedule_data in class_schedule_data:
                ClassSchedule.objects.create(syllabus=instance, **schedule_data)

        return instance


class SyllabusPartialUpdateSerializer(serializers.ModelSerializer):
    """シラバス部分更新用シリアライザ"""

    class Meta:
        model = Syllabus
        fields = [
            'subject_name', 'academic_subject_name',
            'instructor', 'instructor_type', 'teaching_method',
            'class_hours', 'recommended_year', 'course_classification',
            'academic_year', 'semester', 'eligible_departments',
            'course_overview', 'learning_objectives',
            'grading_prerequisites', 'grading_criteria',
            'self_study_required', 'textbook', 'certification',
            'textbook_cost', 'certification_cost', 'notes', 'remarks'
        ]
        # すべてのフィールドをオプションにする
        extra_kwargs = {field: {'required': False} for field in fields}
```

### 5.3 シリアライザの特徴

1. **用途別の分離**: 読み取り/作成/更新で異なるシリアライザを使用
2. **ネストしたシリアライザ**: class_scheduleをネストして処理
3. **バリデーション**: カスタムバリデーションで入力チェック
4. **トランザクション処理**: create/updateメソッドで関連データを一括処理

## 6. ビュー設計

### 6.1 SyllabusViewSet

```python
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from .models import Syllabus
from .serializers import (
    SyllabusSerializer,
    SyllabusCreateSerializer,
    SyllabusPartialUpdateSerializer
)

class SyllabusViewSet(viewsets.ModelViewSet):
    """
    シラバスのCRUD操作を提供するViewSet

    list:       GET /api/syllabi/          - シラバス一覧取得
    create:     POST /api/syllabi/         - シラバス登録
    retrieve:   GET /api/syllabi/{id}/     - シラバス詳細取得
    update:     PUT /api/syllabi/{id}/     - シラバス全更新
    partial_update: PATCH /api/syllabi/{id}/ - シラバス部分更新
    destroy:    DELETE /api/syllabi/{id}/  - シラバス削除
    """

    queryset = Syllabus.objects.all().prefetch_related('class_schedule')

    def get_serializer_class(self):
        """アクションに応じたシリアライザを返す"""
        if self.action in ['create', 'update']:
            return SyllabusCreateSerializer
        elif self.action == 'partial_update':
            return SyllabusPartialUpdateSerializer
        return SyllabusSerializer

    def list(self, request, *args, **kwargs):
        """シラバス一覧取得"""
        queryset = self.filter_queryset(self.get_queryset())
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    def create(self, request, *args, **kwargs):
        """シラバス登録"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)

        # 作成したオブジェクトを詳細シリアライザで返す
        output_serializer = SyllabusSerializer(serializer.instance)
        return Response(
            output_serializer.data,
            status=status.HTTP_201_CREATED
        )

    def retrieve(self, request, *args, **kwargs):
        """シラバス詳細取得"""
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    def update(self, request, *args, **kwargs):
        """シラバス全更新"""
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        # 更新したオブジェクトを詳細シリアライザで返す
        output_serializer = SyllabusSerializer(serializer.instance)
        return Response(output_serializer.data)

    def partial_update(self, request, *args, **kwargs):
        """シラバス部分更新"""
        instance = self.get_object()
        serializer = self.get_serializer(
            instance,
            data=request.data,
            partial=True
        )
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        # 更新したオブジェクトを詳細シリアライザで返す
        output_serializer = SyllabusSerializer(serializer.instance)
        return Response(output_serializer.data)

    def destroy(self, request, *args, **kwargs):
        """シラバス削除"""
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)
```

### 6.2 ビューの特徴

1. **ModelViewSet**: 標準的なCRUD操作を自動提供
2. **シリアライザの使い分け**: アクションに応じて適切なシリアライザを選択
3. **N+1問題の回避**: prefetch_relatedで関連データを効率的に取得
4. **レスポンス形式の統一**: 作成・更新後は詳細シリアライザでレスポンス

## 7. URL設計

### 7.1 URLパターン

```python
# tutorial/urls.py
from django.urls import include, path
from rest_framework import routers
from syllabus import views as syllabus_views

router = routers.DefaultRouter()
router.register(r'syllabi', syllabus_views.SyllabusViewSet, basename='syllabus')

urlpatterns = [
    path('api/', include(router.urls)),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
]
```

### 7.2 エンドポイント一覧

| メソッド | URL | アクション | 説明 |
|---------|-----|-----------|------|
| GET | /api/syllabi/ | list | シラバス一覧取得 |
| POST | /api/syllabi/ | create | シラバス登録 |
| GET | /api/syllabi/{id}/ | retrieve | シラバス詳細取得 |
| PUT | /api/syllabi/{id}/ | update | シラバス全更新 |
| PATCH | /api/syllabi/{id}/ | partial_update | シラバス部分更新 |
| DELETE | /api/syllabi/{id}/ | destroy | シラバス削除 |

## 8. 環境構築手順

### 8.1 前提条件

- Python 3.14以上
- mise がインストール済み
- uv がインストール済み

### 8.2 セットアップ手順

```bash
# 1. miseで必要なツールをインストール
mise install

# 2. uvで仮想環境を作成（既にある場合はスキップ）
uv venv

# 3. 依存パッケージをインストール
uv pip install django djangorestframework

# 4. 依存関係をpyproject.tomlに追加
# pyproject.tomlを手動で編集するか、以下のコマンドを実行
uv add django djangorestframework

# 5. データベースのマイグレーション
python manage.py makemigrations
python manage.py migrate

# 6. 管理者ユーザーの作成（任意）
python manage.py createsuperuser

# 7. 開発サーバーの起動
python manage.py runserver
```

## 9. 実装手順

### フェーズ1: アプリケーション作成とモデル定義

1. syllabusアプリケーションの作成
   ```bash
   python manage.py startapp syllabus
   ```

2. settings.pyにアプリを登録
   ```python
   INSTALLED_APPS = [
       ...
       'rest_framework',
       'syllabus',
   ]
   ```

3. models.pyにSyllabusとClassScheduleモデルを実装
4. マイグレーションファイルの作成と適用
   ```bash
   python manage.py makemigrations syllabus
   python manage.py migrate
   ```

### フェーズ2: シリアライザの実装

1. serializers.pyファイルの作成
2. ClassScheduleSerializer, ClassScheduleCreateSerializer実装
3. SyllabusSerializer, SyllabusCreateSerializer, SyllabusPartialUpdateSerializer実装
4. バリデーションロジックの実装

### フェーズ3: ビューの実装

1. views.pyにSyllabusViewSetを実装
2. get_serializer_classメソッドの実装
3. 各アクション（list, create, retrieve, update, partial_update, destroy）の実装
4. エラーハンドリングの実装

### フェーズ4: URLルーティングの設定

1. syllabus/urls.pyファイルの作成（必要に応じて）
2. tutorial/urls.pyにルーターを設定
3. エンドポイントの動作確認

### フェーズ5: 管理画面の設定

1. admin.pyにモデルを登録
2. 管理画面での表示カスタマイズ

### フェーズ6: テストの実装

1. tests.pyにテストケースを実装
   - モデルのテスト
   - シリアライザのテスト
   - APIエンドポイントのテスト
2. テストの実行
   ```bash
   python manage.py test syllabus
   ```

### フェーズ7: API仕様書の検証

1. 実装したAPIがopenapi.yamlの仕様に準拠しているか確認
2. 必要に応じてAPI仕様書の更新
3. API仕様書の再生成（Redoc等）

## 10. セキュリティ考慮事項

### 10.1 入力バリデーション

- すべての入力データはシリアライザでバリデーション
- SQLインジェクション対策: DjangoのORMを使用
- XSS対策: Django REST frameworkが自動的にエスケープ処理

### 10.2 認証・認可（将来の拡張）

現時点では認証なしで実装しますが、将来的には以下を検討：
- JWT認証の導入
- パーミッションクラスの実装
- ユーザーごとのアクセス制御

### 10.3 その他のセキュリティ対策

- SECRET_KEYの環境変数化
- DEBUGモードの本番環境での無効化
- ALLOWED_HOSTSの適切な設定
- CORS設定（フロントエンドと連携する場合）

## 11. パフォーマンス最適化

### 11.1 データベースクエリの最適化

- `select_related()`: 1:1, N:1のリレーション
- `prefetch_related()`: 1:N, N:Nのリレーション（class_scheduleで使用）

### 11.2 ページネーション

settings.pyで既に設定済み：
```python
REST_FRAMEWORK = {
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 10,
}
```

### 11.3 キャッシング（将来の拡張）

- Redis等のキャッシュシステムの導入検討
- よくアクセスされるエンドポイントのキャッシング

## 12. 今後の拡張案

1. **フィルタリング機能**
   - django-filterの導入
   - 年度・学科・教員名などでのフィルタリング

2. **検索機能**
   - 科目名や内容での全文検索

3. **エクスポート機能**
   - PDF形式でのシラバス出力
   - CSV形式でのデータエクスポート

4. **バージョン管理**
   - シラバスの変更履歴管理
   - django-simple-historyの導入

5. **承認フロー**
   - シラバスの下書き・承認待ち・公開のステータス管理
   - ワークフロー機能の実装

## 13. 参考資料

- [Django公式ドキュメント](https://docs.djangoproject.com/)
- [Django REST framework公式ドキュメント](https://www.django-rest-framework.org/)
- [OpenAPI 3.0仕様](https://swagger.io/specification/)
- プロジェクトのopenapi.yaml

---

**作成日**: 2025-11-12
**バージョン**: 1.0
