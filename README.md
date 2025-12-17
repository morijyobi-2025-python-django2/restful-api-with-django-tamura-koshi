# Syllabus API - RESTful API with Django

シラバス管理のためのRESTful APIプロジェクト

## 📋 概要

Django REST frameworkを使用したシラバス管理API。教育機関のシラバス情報とコマシラバス（授業回詳細）を管理します。

## ✨ 主な機能

- ✅ シラバスのCRUD操作（作成・取得・更新・削除）
- ✅ コマシラバスのネスト表示
- ✅ ページネーション（デフォルト10件/ページ）
- ✅ フィルタリング（年度・学期・教員名等）
- ✅ 全文検索（科目名・教員名・授業概要等）
- ✅ 認証・認可（読み取りは公開、書き込みは認証必要）
- ✅ Django管理画面サポート

## 🛠 技術スタック

- **Python**: 3.14
- **Django**: 6.0
- **Django REST Framework**: 最新版
- **Database**: SQLite3 (開発環境)
- **Package Manager**: uv
- **Runtime Manager**: mise

## 📦 セットアップ

### 1. リポジトリクローン

```bash
git clone https://github.com/morijyobi-2025-python-django2/restful-api-with-django-tamura-koshi.git
cd restful-api-with-django-tamura-koshi
```

### 2. Python環境セットアップ

```bash
# miseでPythonバージョン管理（推奨）
mise install

# または手動でPython 3.14をインストール
```

### 3. 依存関係インストール

```bash
# uvを使用（推奨）
uv sync

# または pip
pip install -r requirements.txt
```

### 4. データベースマイグレーション

```bash
uv run python manage.py migrate
```

### 5. テストデータ投入（オプション）

```bash
uv run python manage.py loaddata syllabus/fixtures/initial_data.json
```

### 6. スーパーユーザー作成（管理画面用）

```bash
uv run python manage.py createsuperuser
```

### 7. 開発サーバー起動

```bash
uv run python manage.py runserver
```

サーバーが起動したら http://localhost:8000 でアクセス可能です。

## 🔌 API エンドポイント

### ベースURL
```
http://localhost:8000/api/
```

### シラバスAPI

| メソッド | エンドポイント | 認証 | 説明 |
|---------|--------------|------|------|
| GET | `/api/syllabi/` | 不要 | シラバス一覧取得 |
| POST | `/api/syllabi/` | 必要 | シラバス作成 |
| GET | `/api/syllabi/{id}/` | 不要 | シラバス詳細取得 |
| PUT | `/api/syllabi/{id}/` | 必要 | シラバス全更新 |
| PATCH | `/api/syllabi/{id}/` | 必要 | シラバス部分更新 |
| DELETE | `/api/syllabi/{id}/` | 必要 | シラバス削除 |

### 管理画面
- URL: http://localhost:8000/admin/
- 認証: スーパーユーザーのみ

## 📖 使用例

### シラバス一覧取得
```bash
curl http://localhost:8000/api/syllabi/
```

### シラバス詳細取得
```bash
curl http://localhost:8000/api/syllabi/1/
```

### フィルタリング
```bash
# 年度でフィルタ
curl "http://localhost:8000/api/syllabi/?academic_year=2025"

# 学期でフィルタ
curl "http://localhost:8000/api/syllabi/?semester=後期"

# 教員名でフィルタ
curl "http://localhost:8000/api/syllabi/?teacher_name=鈴木亮"

# 複数条件
curl "http://localhost:8000/api/syllabi/?academic_year=2025&semester=後期"
```

### 検索
```bash
# キーワード検索（科目名・教員名・授業概要等）
curl "http://localhost:8000/api/syllabi/?search=Django"
```

### ページネーション
```bash
# 2ページ目を取得
curl "http://localhost:8000/api/syllabi/?page=2"

# ページサイズ指定
curl "http://localhost:8000/api/syllabi/?page_size=5"
```

### シラバス作成（認証必要）
```bash
curl -X POST http://localhost:8000/api/syllabi/ \
  -H "Content-Type: application/json" \
  -u username:password \
  -d '{
    "subject_name": "Python基礎",
    "regulation_subject_name": "プログラミング演習",
    "teacher_name": "山田太郎",
    "instructor_type": "専任教員",
    "teaching_method": "講義",
    "num_sessions": 15,
    "recommended_grade": "1年～",
    "enrollment_classification": "必修",
    "academic_year": 2025,
    "semester": "前期",
    "eligible_departments": ["情報システム科"]
  }'
```

## 🗂 プロジェクト構造

```
.
├── manage.py                    # Django管理スクリプト
├── pyproject.toml              # プロジェクト設定（uv用）
├── docs/                       # ドキュメント
│   ├── design.md              # 設計書
│   ├── IMPLEMENTATION_PLAN.md # 実装計画書
│   ├── api-test-results.md    # API動作確認結果
│   └── openapi.yaml           # OpenAPI仕様
├── tutorial/                   # Djangoプロジェクト設定
│   └── tutorial/
│       ├── settings.py        # Django設定
│       └── urls.py            # URLルーティング
└── syllabus/                   # シラバスアプリ
    ├── models.py              # データモデル
    ├── serializers.py         # シリアライザー
    ├── views.py               # ビュー（ViewSet）
    ├── admin.py               # 管理画面設定
    └── fixtures/              # テストデータ
        └── initial_data.json  # 初期データ
```

## 📚 データモデル

### Syllabus（シラバス）
- 基本情報: 科目名、学則科目名、担当教員
- 授業情報: 授業方法、コマ数、推奨履修年次、履修分類
- 開講情報: 開講年度、開講期間、履修可能学科
- 授業内容: 授業概要、到達目標、成績評価基準等
- 自動フィールド: created_at, updated_at

### ClassSession（コマシラバス）
- シラバスへの外部キー（1:N）
- 順番、コマ数、授業内容

詳細は `openapi.yaml` を参照してください。

## 🔐 認証

APIは `IsAuthenticatedOrReadOnly` パーミッションを使用：
- **GET**: 認証不要（誰でもアクセス可能）
- **POST/PUT/PATCH/DELETE**: 認証必要

### 認証方法

#### 1. Basic認証
```bash
curl -u username:password http://localhost:8000/api/syllabi/
```

#### 2. セッション認証
ブラウザで http://localhost:8000/api-auth/login/ にアクセスしてログイン

#### 3. Django管理画面
http://localhost:8000/admin/ からデータを直接編集

## 🧪 テスト

### API動作確認
```bash
# 開発サーバー起動
uv run python manage.py runserver

# 別ターミナルでテスト実行
curl http://localhost:8000/api/syllabi/
```

テスト結果の詳細: `docs/api-test-results.md`

### Djangoテスト（今後実装予定）
```bash
uv run python manage.py test syllabus
```

## 📝 開発

### マイグレーション作成
```bash
uv run python manage.py makemigrations
```

### マイグレーション適用
```bash
uv run python manage.py migrate
```

### Django Shell
```bash
uv run python manage.py shell
```

### 静的解析
```bash
uv run python manage.py check
```

## 📄 ドキュメント

- [設計書](docs/design.md): 詳細な設計仕様
- [実装計画書](docs/IMPLEMENTATION_PLAN.md): フェーズごとの実装ガイド
- [API動作確認結果](docs/api-test-results.md): テスト結果
- [OpenAPI仕様](openapi.yaml): API仕様書
- [Swagger UI](docs/index.html): APIドキュメント（Swagger）

## 🤝 コントリビューション

1. フォークする
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. コミット (`git commit -m 'Add amazing feature'`)
4. プッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📜 ライセンス

このプロジェクトは教育目的で作成されています。

## 👥 作成者

盛岡情報ビジネス＆デザイン専門学校
- Python応用(Django)② 2025年度後期

## 📞 サポート

問題が発生した場合:
1. [Issues](https://github.com/morijyobi-2025-python-django2/restful-api-with-django-tamura-koshi/issues) を確認
2. 新しいIssueを作成
3. [ドキュメント](docs/) を参照
