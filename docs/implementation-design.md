# Syllabus API 実装設計書

## 1. 概要

openapi.yamlで定義されたシラバス管理APIをDjango REST frameworkで実装する。

### 技術スタック
- Python 3.14
- Django 6.0
- Django REST framework
- uv (パッケージ管理)
- mise (Python バージョン管理)
- SQLite (開発環境DB)

## 2. データモデル設計

### 2.1 Syllabusモデル

| フィールド名 | 型 | 制約 | 説明 |
|------------|---|-----|-----|
| id | Integer | PK, AutoIncrement | シラバスID |
| subject_name | CharField(200) | NOT NULL | 科目名 |
| regulation_subject_name | CharField(200) | NOT NULL | 学則科目名 |
| teacher_name | CharField(100) | NOT NULL | 担当教員 |
| instructor_type | CharField(20) | NOT NULL, Choices | 講師区分 (専任教員/実務教員/非常勤講師) |
| teaching_method | CharField(100) | NOT NULL | 授業方法 |
| num_sessions | Integer | NOT NULL | 授業コマ数 |
| recommended_grade | CharField(50) | NOT NULL | 推奨履修年次 |
| enrollment_classification | CharField(20) | NOT NULL, Choices | 履修分類 (必修/必修選択/選択) |
| academic_year | Integer | NOT NULL | 開講年度 |
| semester | CharField(20) | NOT NULL, Choices | 開講期間 (前期/後期/通年) |
| eligible_departments | JSONField | default=list | 履修可能学科 (配列) |
| course_overview | TextField | blank=True | 授業概要 |
| learning_objectives | TextField | blank=True | 到達目標 |
| grading_prerequisites | TextField | blank=True | 成績評価の前提条件 |
| grading_criteria | TextField | blank=True | 成績評価基準 |
| required_study_outside_class | TextField | blank=True | 授業外に必要な学習内容 |
| textbook | TextField | blank=True | 教材 |
| certification | TextField | blank=True | 検定 |
| textbook_cost | TextField | blank=True | 教材費 |
| certification_cost | TextField | blank=True | 検定費 |
| notes | TextField | blank=True | 履修にあたっての留意点 |
| remarks | TextField | blank=True | 備考 |
| created_at | DateTimeField | auto_now_add | 作成日時 |
| updated_at | DateTimeField | auto_now | 更新日時 |

### 2.2 ClassSessionモデル

| フィールド名 | 型 | 制約 | 説明 |
|------------|---|-----|-----|
| id | Integer | PK, AutoIncrement | コマシラバスID |
| syllabus | ForeignKey | NOT NULL, CASCADE | シラバス (Syllabus) |
| order | Integer | NOT NULL | 授業の順番 |
| num_sessions | Integer | NOT NULL | コマ数 |
| content | TextField | NOT NULL | 授業内容 |

**リレーション:**
- Syllabus : ClassSession = 1 : N
- related_name: `class_sessions`

## 3. APIエンドポイント設計

### 3.1 ベースURL
```
http://localhost:8000/api/
```

### 3.2 エンドポイント一覧

| メソッド | パス | 認証 | 説明 |
|---------|------|-----|-----|
| GET | /api/syllabi/ | 不要 | シラバス一覧取得 (ページネーション) |
| POST | /api/syllabi/ | 必要 | シラバス新規作成 |
| GET | /api/syllabi/{id}/ | 不要 | シラバス詳細取得 |
| PUT | /api/syllabi/{id}/ | 必要 | シラバス全更新 |
| PATCH | /api/syllabi/{id}/ | 必要 | シラバス部分更新 |
| DELETE | /api/syllabi/{id}/ | 必要 | シラバス削除 |

### 3.3 クエリパラメータ

#### GET /api/syllabi/
- `page`: ページ番号 (integer, >= 1)
- `page_size`: 1ページあたりの件数 (integer, 1-100)
- `academic_year`: 開講年度でフィルタ
- `semester`: 開講期間でフィルタ
- `teacher_name`: 担当教員名でフィルタ
- `search`: 科目名・教員名などで検索

## 4. 実装ファイル構成

```
syllabus/
├── __init__.py
├── models.py          # Syllabus, ClassSession モデル
├── serializers.py     # SyllabusSerializer, ClassSessionSerializer
├── views.py           # SyllabusViewSet
├── admin.py           # 管理画面設定
├── tests.py           # テストコード
└── migrations/
    └── 0001_initial.py

tutorial/tutorial/
├── settings.py        # INSTALLED_APPS に syllabus 追加
└── urls.py            # router に syllabus 登録
```

## 5. 実装手順

### Step 1: モデル定義
1. `syllabus/models.py` に Syllabus, ClassSession モデルを定義
2. Choices を使って enum フィールドを実装
3. JSONField で eligible_departments を実装

### Step 2: マイグレーション
```bash
uv run python manage.py makemigrations syllabus
uv run python manage.py migrate
```

### Step 3: シリアライザー実装
1. `syllabus/serializers.py` に ClassSessionSerializer を作成
2. SyllabusSerializer を作成 (class_sessions をネスト)
3. read_only_fields を設定 (id, created_at, updated_at)

### Step 4: ビュー実装
1. `syllabus/views.py` に SyllabusViewSet を作成
2. ModelViewSet を継承
3. permission_classes で認証制御
   - GET: AllowAny
   - POST/PUT/PATCH/DELETE: IsAuthenticated
4. filterset_fields でフィルタリング設定
5. search_fields で検索設定
6. ページネーション設定 (settings.py)

### Step 5: URL設定
1. `tutorial/tutorial/urls.py` にルーティング追加
2. DefaultRouter で syllabi エンドポイントを登録
3. ベースURLを `/api/` に設定

### Step 6: 管理画面設定
1. `syllabus/admin.py` に Syllabus, ClassSession を登録
2. TabularInline で ClassSession を Syllabus 編集画面に表示
3. list_display, list_filter, search_fields を設定

### Step 7: 初期データ投入
```bash
uv run python manage.py createsuperuser
```

### Step 8: 動作確認
```bash
uv run python manage.py runserver
```

確認項目:
- [ ] GET /api/syllabi/ でシラバス一覧取得
- [ ] GET /api/syllabi/{id}/ でシラバス詳細取得
- [ ] POST /api/syllabi/ でシラバス作成 (認証必要)
- [ ] PUT /api/syllabi/{id}/ でシラバス更新 (認証必要)
- [ ] PATCH /api/syllabi/{id}/ で部分更新 (認証必要)
- [ ] DELETE /api/syllabi/{id}/ でシラバス削除 (認証必要)
- [ ] ページネーション動作確認
- [ ] フィルタリング動作確認
- [ ] 検索機能動作確認

## 6. 認証設定

### settings.py に追加
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}
```

### パーミッション設定
```python
from rest_framework import permissions

class SyllabusViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
```

## 7. テスト方針

### 7.1 単体テスト
- モデルのバリデーションテスト
- シリアライザーのテスト
- ビューの各HTTPメソッドのテスト

### 7.2 結合テスト
- API エンドポイントの動作確認
- 認証・認可のテスト
- ページネーションのテスト
- フィルタリング・検索のテスト

### 7.3 テストツール
- Django TestCase
- Django REST framework APITestCase
- pytest (オプション)

## 8. 注意事項

1. **既存データとの互換性**
   - 既に syllabus アプリが存在する場合、マイグレーション時に既存データとの整合性に注意
   - 必要に応じてデータマイグレーションを作成

2. **セキュリティ**
   - CSRF 保護を有効化
   - CORS 設定を適切に行う
   - 本番環境では SECRET_KEY を環境変数化

3. **パフォーマンス**
   - N+1問題を避けるため、class_sessions は select_related/prefetch_related を使用
   - 大量データの場合、ページネーションサイズを調整

4. **バリデーション**
   - 必須フィールドのチェック
   - enum フィールドの値検証
   - 数値フィールドの範囲チェック

## 9. 今後の拡張

- [ ] フィルタリング機能の拡充 (django-filter)
- [ ] 全文検索機能 (Elasticsearch)
- [ ] API ドキュメント自動生成 (drf-spectacular)
- [ ] API バージョニング
- [ ] レート制限
- [ ] キャッシング
