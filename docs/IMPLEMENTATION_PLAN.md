# Syllabus API 実装計画書

## 文書情報
- **作成日**: 2025-12-17
- **バージョン**: 1.0
- **参照**: openapi.yaml, docs/design.md

## 1. プロジェクト概要

### 1.1 目的
OpenAPI仕様(openapi.yaml)に基づき、シラバス管理のためのRESTful APIをDjango REST frameworkで実装する。

### 1.2 スコープ
- シラバス情報のCRUD操作
- コマシラバス（授業回詳細）の管理
- ページネーション、フィルタリング、検索機能
- 認証・認可機能

### 1.3 技術スタック
- **言語**: Python 3.14
- **フレームワーク**: Django 5.2.7 / Django REST framework
- **パッケージ管理**: uv
- **ランタイム管理**: mise
- **データベース**: SQLite3 (開発環境)
- **API仕様**: OpenAPI 3.0.0

## 2. 前提条件と制約

### 2.1 前提条件
- ✅ Djangoプロジェクト `tutorial` が存在
- ✅ Django REST framework がインストール済み
- ✅ `syllabus` アプリが既に作成済み
- ✅ openapi.yaml が定義済み
- ✅ スーパーユーザーが作成済み

### 2.2 制約事項
- 既存の `syllabus` アプリのモデル定義が openapi.yaml と不一致
- 既存のマイグレーションファイルが存在する可能性
- ルートディレクトリと tutorial/manage.py が混在

### 2.3 前提確認項目
```bash
# 確認コマンド
uv run python manage.py showmigrations syllabus
ls -la syllabus/
cat syllabus/models.py | head -20
```

## 3. 実装計画

### Phase 1: 準備・環境確認 (30分)

#### タスク 1.1: 現状確認
- [ ] 既存モデル定義の確認
- [ ] 既存マイグレーション状況の確認
- [ ] データベースの状態確認
- [ ] openapi.yaml との差分確認

**コマンド:**
```bash
cd /path/to/project
uv run python manage.py showmigrations
sqlite3 db.sqlite3 ".tables"
git status
```

#### タスク 1.2: バックアップ
- [ ] 既存コードのバックアップ (git commit)
- [ ] データベースのバックアップ (該当する場合)

**コマンド:**
```bash
git add -A
git commit -m "chore: Backup before API implementation"
cp db.sqlite3 db.sqlite3.backup
```

### Phase 2: モデル実装 (1時間)

#### タスク 2.1: モデル定義の更新
**ファイル**: `syllabus/models.py`

**実装内容:**
1. `Syllabus` モデルを openapi.yaml に合わせて定義
   - 必須フィールド: subject_name, regulation_subject_name, teacher_name, instructor_type, teaching_method, num_sessions, recommended_grade, enrollment_classification, academic_year, semester
   - Choices: instructor_type (3種類), enrollment_classification (3種類), semester (3種類)
   - JSONField: eligible_departments
   - TextField: 説明文系フィールド (blank=True)

2. `ClassSession` モデルの定義
   - ForeignKey: syllabus (CASCADE)
   - フィールド: order, num_sessions, content
   - related_name: 'class_sessions'
   - ordering: ['order']

**成功基準:**
- コードがエラーなく保存される
- モデルの __str__ メソッドが適切に実装されている

#### タスク 2.2: マイグレーション作成
**コマンド:**
```bash
# 既存マイグレーションの削除 (必要な場合)
rm -rf syllabus/migrations/0*.py

# __init__.py の再作成
touch syllabus/migrations/__init__.py

# 新しいマイグレーション作成
uv run python manage.py makemigrations syllabus
```

**対処方法:**
- フィールド名変更の確認が出た場合: すべて `n` (No) を選択
- データ損失の警告: `yes` で承認 (開発環境のため)

**成功基準:**
- `syllabus/migrations/0001_initial.py` が生成される
- エラーなくマイグレーションファイルが作成される

#### タスク 2.3: マイグレーション適用
**コマンド:**
```bash
uv run python manage.py migrate syllabus
```

**成功基準:**
- マイグレーションが適用される
- データベーステーブルが作成される
- エラーが発生しない

### Phase 3: シリアライザー実装 (45分)

#### タスク 3.1: ClassSessionSerializer 実装
**ファイル**: `syllabus/serializers.py`

**実装内容:**
```python
from rest_framework import serializers
from .models import Syllabus, ClassSession


class ClassSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClassSession
        fields = ['id', 'order', 'num_sessions', 'content']
        read_only_fields = ['id']
```

**成功基準:**
- フィールドが openapi.yaml の ClassSession スキーマと一致
- id が read_only

#### タスク 3.2: SyllabusSerializer 実装
**実装内容:**
```python
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
```

**成功基準:**
- すべてのフィールドが openapi.yaml の Syllabus スキーマと一致
- class_sessions がネストされている
- read_only_fields が適切に設定されている

### Phase 4: ビュー実装 (45分)

#### タスク 4.1: SyllabusViewSet 実装
**ファイル**: `syllabus/views.py`

**実装内容:**
```python
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
```

**成功基準:**
- ModelViewSet を継承している
- IsAuthenticatedOrReadOnly でGET以外は認証必要
- N+1問題対策で prefetch_related 使用
- filterset_fields と search_fields が設定されている

### Phase 5: URL設定 (30分)

#### タスク 5.1: settings.py の更新
**ファイル**: `tutorial/tutorial/settings.py`

**実装内容:**
1. INSTALLED_APPS に 'syllabus' を追加 (既に追加されている場合はスキップ)
2. REST_FRAMEWORK 設定を追加/更新

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'syllabus',  # ← 追加
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
    'DEFAULT_FILTER_BACKENDS': [
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}
```

**成功基準:**
- 設定エラーが発生しない
- サーバー起動時にエラーが出ない

#### タスク 5.2: urls.py の更新
**ファイル**: `tutorial/tutorial/urls.py`

**実装内容:**
```python
from django.contrib import admin
from django.urls import include, path
from rest_framework import routers

from quickstart import views as quickstart_views
from syllabus import views as syllabus_views

router = routers.DefaultRouter()
router.register(r'users', quickstart_views.UserViewSet)
router.register(r'groups', quickstart_views.GroupViewSet)
router.register(r'syllabi', syllabus_views.SyllabusViewSet, basename='syllabus')

urlpatterns = [
    path('api/', include(router.urls)),
    path('admin/', admin.site.urls),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
]
```

**成功基準:**
- /api/syllabi/ でルーティングされる
- basename が 'syllabus' に設定されている
- エラーなく起動する

### Phase 6: 管理画面設定 (30分)

#### タスク 6.1: admin.py の実装
**ファイル**: `syllabus/admin.py`

**実装内容:**
```python
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
```

**成功基準:**
- 管理画面でシラバス一覧が表示される
- インラインでコマシラバスが編集できる
- フィールドセットで整理されている

### Phase 7: テストデータ作成 (30分)

#### タスク 7.1: 管理画面からテストデータ投入

**手順:**
1. サーバー起動: `uv run python manage.py runserver`
2. 管理画面にアクセス: http://localhost:8000/admin/
3. Syllabus を1件作成
4. ClassSession を3件作成

**テストデータ例:**
```
【シラバス】
- 科目名: Python応用(Django)②
- 学則科目名: システム開発演習
- 担当教員: 鈴木亮
- 講師区分: 実務教員
- 授業方法: 講義&演習
- 授業コマ数: 30
- 推奨履修年次: 2年～
- 履修分類: 必修選択
- 開講年度: 2025
- 開講期間: 後期
- 履修可能学科: ["高度情報工学科", "総合システム工学科"]

【コマシラバス】
1. 順番:1, コマ数:1, 内容: オリエンテーション
2. 順番:2, コマ数:2, 内容: Django基礎
3. 順番:3, コマ数:2, 内容: REST API実装
```

**成功基準:**
- エラーなく保存される
- 一覧画面で表示される

### Phase 8: API動作確認 (1時間)

#### タスク 8.1: GET /api/syllabi/ の確認

**テスト方法:**
```bash
# ブラウザ
http://localhost:8000/api/syllabi/

# curl
curl http://localhost:8000/api/syllabi/

# httpie
http GET http://localhost:8000/api/syllabi/
```

**確認項目:**
- [ ] ステータスコード 200
- [ ] ページネーション情報が含まれる (count, next, previous, results)
- [ ] シラバス一覧が返される
- [ ] class_sessions がネストされている

#### タスク 8.2: GET /api/syllabi/{id}/ の確認

**テスト方法:**
```bash
curl http://localhost:8000/api/syllabi/1/
```

**確認項目:**
- [ ] ステータスコード 200
- [ ] 指定IDのシラバスが返される
- [ ] すべてのフィールドが含まれる

#### タスク 8.3: POST /api/syllabi/ の確認

**テスト方法:**
```bash
curl -X POST http://localhost:8000/api/syllabi/ \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{
    "subject_name": "テスト科目",
    "regulation_subject_name": "テスト学則科目",
    "teacher_name": "テスト教員",
    "instructor_type": "実務教員",
    "teaching_method": "講義",
    "num_sessions": 15,
    "recommended_grade": "1年～",
    "enrollment_classification": "選択",
    "academic_year": 2025,
    "semester": "前期",
    "eligible_departments": ["情報システム科"]
  }'
```

**確認項目:**
- [ ] 認証なし → 401エラー
- [ ] 認証あり → 201 Created
- [ ] 作成されたシラバスが返される
- [ ] 必須フィールドなし → 400エラー

#### タスク 8.4: PUT /api/syllabi/{id}/ の確認

**テスト方法:**
```bash
curl -X PUT http://localhost:8000/api/syllabi/1/ \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{...全フィールド...}'
```

**確認項目:**
- [ ] 認証なし → 401エラー
- [ ] 認証あり → 200 OK
- [ ] 更新されたデータが返される

#### タスク 8.5: PATCH /api/syllabi/{id}/ の確認

**テスト方法:**
```bash
curl -X PATCH http://localhost:8000/api/syllabi/1/ \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{"subject_name": "更新後の科目名"}'
```

**確認項目:**
- [ ] 部分更新が成功する
- [ ] 他のフィールドは変更されない

#### タスク 8.6: DELETE /api/syllabi/{id}/ の確認

**テスト方法:**
```bash
curl -X DELETE http://localhost:8000/api/syllabi/1/ \
  -u admin:password
```

**確認項目:**
- [ ] 認証なし → 401エラー
- [ ] 認証あり → 204 No Content
- [ ] データが削除される

#### タスク 8.7: フィルタリングの確認

**テスト方法:**
```bash
# 年度でフィルタ
curl "http://localhost:8000/api/syllabi/?academic_year=2025"

# 学期でフィルタ
curl "http://localhost:8000/api/syllabi/?semester=後期"

# 複数条件
curl "http://localhost:8000/api/syllabi/?academic_year=2025&semester=後期"
```

**確認項目:**
- [ ] フィルタ条件に合致するデータのみ返される

#### タスク 8.8: 検索の確認

**テスト方法:**
```bash
curl "http://localhost:8000/api/syllabi/?search=Django"
```

**確認項目:**
- [ ] 科目名・教員名などで部分一致検索できる

#### タスク 8.9: ページネーションの確認

**テスト方法:**
```bash
# デフォルト (10件/ページ)
curl "http://localhost:8000/api/syllabi/"

# ページ指定
curl "http://localhost:8000/api/syllabi/?page=2"

# ページサイズ指定
curl "http://localhost:8000/api/syllabi/?page_size=5"
```

**確認項目:**
- [ ] PAGE_SIZE の設定が有効
- [ ] next/previous のURLが正しい
- [ ] count が正しい

### Phase 9: ドキュメント更新 (30分)

#### タスク 9.1: README.md の更新

**追加内容:**
- API エンドポイント一覧
- 使用例
- 認証方法
- フィルタリング・検索方法

#### タスク 9.2: コミット

**コマンド:**
```bash
git add .
git commit -m "feat: Implement Syllabus API

- Add Syllabus and ClassSession models
- Add serializers with nested ClassSession
- Add SyllabusViewSet with CRUD operations
- Configure authentication and pagination
- Add admin interface
- Update URL routing"
```

## 4. 成功基準

### 4.1 機能要件
- ✅ すべてのCRUD操作が動作する
- ✅ 認証・認可が正しく機能する
- ✅ ページネーションが動作する
- ✅ フィルタリングが動作する
- ✅ 検索が動作する
- ✅ コマシラバスがネストされて取得できる

### 4.2 非機能要件
- ✅ openapi.yaml の仕様と一致する
- ✅ エラーハンドリングが適切
- ✅ コードが読みやすい
- ✅ 管理画面で編集できる

## 5. リスクと対策

### リスク 1: 既存データとの不整合
**対策:**
- マイグレーション前にバックアップを取る
- 必要に応じてデータマイグレーションを作成
- テスト環境で先に実行する

### リスク 2: フィールド名の不一致
**対策:**
- openapi.yaml と design.md の差分を事前に確認
- 統一した命名規則を使用
- シリアライザーで field_name マッピングを使用

### リスク 3: N+1問題
**対策:**
- prefetch_related で関連データを事前取得
- django-debug-toolbar で確認

## 6. スケジュール

| Phase | 作業内容 | 所要時間 | 累計時間 |
|-------|---------|---------|---------|
| 1 | 準備・環境確認 | 30分 | 30分 |
| 2 | モデル実装 | 1時間 | 1.5時間 |
| 3 | シリアライザー実装 | 45分 | 2.25時間 |
| 4 | ビュー実装 | 45分 | 3時間 |
| 5 | URL設定 | 30分 | 3.5時間 |
| 6 | 管理画面設定 | 30分 | 4時間 |
| 7 | テストデータ作成 | 30分 | 4.5時間 |
| 8 | API動作確認 | 1時間 | 5.5時間 |
| 9 | ドキュメント更新 | 30分 | 6時間 |

**合計: 約6時間**

## 7. チェックリスト

### 実装前
- [ ] openapi.yaml を確認
- [ ] design.md を確認
- [ ] 既存コードをバックアップ
- [ ] 作業ブランチを作成

### 実装中
- [ ] Phase 1 完了
- [ ] Phase 2 完了
- [ ] Phase 3 完了
- [ ] Phase 4 完了
- [ ] Phase 5 完了
- [ ] Phase 6 完了
- [ ] Phase 7 完了
- [ ] Phase 8 完了
- [ ] Phase 9 完了

### 完了後
- [ ] すべてのAPIが動作する
- [ ] テストデータで確認済み
- [ ] ドキュメントを更新
- [ ] コミット・プッシュ
- [ ] プルリクエスト作成

## 8. 参考コマンド集

```bash
# サーバー起動
uv run python manage.py runserver

# マイグレーション
uv run python manage.py makemigrations
uv run python manage.py migrate

# 管理画面
uv run python manage.py createsuperuser

# シェル
uv run python manage.py shell

# テスト
uv run python manage.py test syllabus

# 静的解析
uv run python manage.py check
```

## 9. トラブルシューティング

### エラー: ModuleNotFoundError: No module named 'syllabus'
**原因:** INSTALLED_APPS に追加されていない
**解決:** settings.py の INSTALLED_APPS に 'syllabus' を追加

### エラー: マイグレーション時にフィールド名変更を聞かれる
**原因:** 既存のマイグレーションとの差分
**解決:** すべて `n` (No) を選択して新規作成

### エラー: 401 Unauthorized
**原因:** 認証が必要な操作で認証情報がない
**解決:** `-u username:password` をcurlに追加

### エラー: N+1問題
**原因:** 関連データを都度クエリしている
**解決:** ViewSet の queryset に `.prefetch_related('class_sessions')` を追加
