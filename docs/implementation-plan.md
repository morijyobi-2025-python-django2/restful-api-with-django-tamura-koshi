# シラバスAPI 実装計画書

本計画書は、openapi.yamlで定義されたシラバスAPIの実装を段階的に進めるためのチェックリストです。
各項目を完了したら `[x]` でマークしてください。

## 前提条件の確認

- [ ] Python 3.14以上がインストールされている
- [ ] miseがインストールされている
- [ ] uvがインストールされている
- [ ] プロジェクトディレクトリに移動済み

---

## フェーズ1: 環境構築とプロジェクト準備

### 1.1 依存パッケージの管理

- [ ] pyproject.tomlの依存関係を確認
- [ ] Django, Django REST frameworkをuvで追加
  ```bash
  uv add django djangorestframework
  ```
- [ ] pyproject.tomlに依存関係が記録されたことを確認

### 1.2 アプリケーションの作成

- [ ] syllabusアプリケーションを作成
  ```bash
  python manage.py startapp syllabus
  ```
- [ ] syllabusディレクトリが作成されたことを確認
- [ ] 以下のファイルが存在することを確認
  - [ ] `syllabus/__init__.py`
  - [ ] `syllabus/models.py`
  - [ ] `syllabus/views.py`
  - [ ] `syllabus/admin.py`
  - [ ] `syllabus/apps.py`
  - [ ] `syllabus/tests.py`
  - [ ] `syllabus/migrations/__init__.py`

### 1.3 settings.pyの設定

- [ ] `tutorial/settings.py`を開く
- [ ] INSTALLED_APPSに`'syllabus'`を追加
  ```python
  INSTALLED_APPS = [
      'django.contrib.admin',
      'django.contrib.auth',
      'django.contrib.contenttypes',
      'django.contrib.sessions',
      'django.contrib.messages',
      'django.contrib.staticfiles',
      'rest_framework',
      'syllabus',  # 追加
  ]
  ```
- [ ] REST_FRAMEWORK設定が存在することを確認（既に設定済み）
- [ ] LANGUAGE_CODEを`'ja'`に変更（任意）
- [ ] TIME_ZONEを`'Asia/Tokyo'`に変更（任意）

---

## フェーズ2: データモデルの実装

### 2.1 Syllabusモデルの実装

- [ ] `syllabus/models.py`を開く
- [ ] 必要なインポートを追加
  ```python
  from django.db import models
  ```
- [ ] Syllabusクラスを作成
- [ ] 基本情報フィールドを実装
  - [ ] `subject_name` (CharField, max_length=255, 必須)
  - [ ] `academic_subject_name` (CharField, max_length=255, nullable)
- [ ] 教員情報フィールドを実装
  - [ ] `instructor` (CharField, max_length=100, nullable)
  - [ ] `instructor_type` (CharField, choices付き, nullable)
  - [ ] INSTRUCTOR_TYPE_CHOICESの定義
- [ ] 授業形態フィールドを実装
  - [ ] `teaching_method` (CharField, choices付き, nullable)
  - [ ] TEACHING_METHOD_CHOICESの定義
  - [ ] `class_hours` (IntegerField, nullable)
- [ ] 履修情報フィールドを実装
  - [ ] `recommended_year` (CharField, max_length=50, nullable)
  - [ ] `course_classification` (CharField, choices付き, nullable)
  - [ ] COURSE_CLASSIFICATION_CHOICESの定義
- [ ] 開講情報フィールドを実装
  - [ ] `academic_year` (IntegerField, 必須)
  - [ ] `semester` (CharField, choices付き, nullable)
  - [ ] SEMESTER_CHOICESの定義
  - [ ] `eligible_departments` (JSONField, default=list)
- [ ] 授業内容フィールドを実装
  - [ ] `course_overview` (TextField, nullable)
  - [ ] `learning_objectives` (TextField, nullable)
- [ ] 評価基準フィールドを実装
  - [ ] `grading_prerequisites` (TextField, nullable)
  - [ ] `grading_criteria` (TextField, nullable)
- [ ] その他の情報フィールドを実装
  - [ ] `self_study_required` (TextField, nullable)
  - [ ] `textbook` (TextField, nullable)
  - [ ] `certification` (TextField, nullable)
  - [ ] `textbook_cost` (CharField, max_length=100, nullable)
  - [ ] `certification_cost` (CharField, max_length=100, nullable)
  - [ ] `notes` (TextField, nullable)
  - [ ] `remarks` (TextField, nullable)
- [ ] 管理用フィールドを実装
  - [ ] `created_at` (DateTimeField, auto_now_add=True)
  - [ ] `updated_at` (DateTimeField, auto_now=True)
- [ ] Metaクラスを実装
  - [ ] `db_table = 'syllabi'`
  - [ ] `verbose_name = 'シラバス'`
  - [ ] `verbose_name_plural = 'シラバス一覧'`
  - [ ] `ordering = ['-academic_year', 'subject_name']`
- [ ] `__str__`メソッドを実装

### 2.2 ClassScheduleモデルの実装

- [ ] 同じく`syllabus/models.py`に追加
- [ ] ClassScheduleクラスを作成
- [ ] フィールドを実装
  - [ ] `syllabus` (ForeignKey to Syllabus, CASCADE, related_name='class_schedule')
  - [ ] `order` (IntegerField)
  - [ ] `class_hours` (IntegerField)
  - [ ] `content` (TextField)
  - [ ] `created_at` (DateTimeField, auto_now_add=True)
  - [ ] `updated_at` (DateTimeField, auto_now=True)
- [ ] Metaクラスを実装
  - [ ] `db_table = 'class_schedules'`
  - [ ] `verbose_name = 'コマシラバス'`
  - [ ] `verbose_name_plural = 'コマシラバス一覧'`
  - [ ] `ordering = ['syllabus', 'order']`
  - [ ] `unique_together = [['syllabus', 'order']]`
- [ ] `__str__`メソッドを実装

### 2.3 マイグレーションの作成と適用

- [ ] マイグレーションファイルを作成
  ```bash
  python manage.py makemigrations syllabus
  ```
- [ ] マイグレーションファイルが生成されたことを確認
  - [ ] `syllabus/migrations/0001_initial.py`の存在確認
- [ ] マイグレーション内容を確認（2つのテーブルが作成される）
- [ ] マイグレーションを適用
  ```bash
  python manage.py migrate syllabus
  ```
- [ ] マイグレーション適用成功のメッセージを確認
- [ ] データベースにテーブルが作成されたことを確認（任意）
  ```bash
  python manage.py dbshell
  .tables  # SQLiteの場合
  .exit
  ```

---

## フェーズ3: シリアライザの実装

### 3.1 serializersファイルの作成

- [ ] `syllabus/serializers.py`ファイルを新規作成
- [ ] 必要なインポートを追加
  ```python
  from rest_framework import serializers
  from .models import Syllabus, ClassSchedule
  ```

### 3.2 ClassScheduleシリアライザの実装

- [ ] ClassScheduleSerializerクラスを作成
  - [ ] ModelSerializerを継承
  - [ ] Metaクラスを定義
  - [ ] model = ClassScheduleを指定
  - [ ] fields = ['id', 'order', 'class_hours', 'content']を指定
  - [ ] read_only_fields = ['id']を指定

- [ ] ClassScheduleCreateSerializerクラスを作成
  - [ ] ModelSerializerを継承
  - [ ] Metaクラスを定義
  - [ ] model = ClassScheduleを指定
  - [ ] fields = ['order', 'class_hours', 'content']を指定
  - [ ] validate_class_hoursメソッドを実装（1以上のチェック）
  - [ ] validate_orderメソッドを実装（1以上のチェック）

### 3.3 Syllabusシリアライザの実装

- [ ] SyllabusSerializerクラスを作成（詳細表示用）
  - [ ] ModelSerializerを継承
  - [ ] class_scheduleフィールドを追加（ClassScheduleSerializer, many=True, read_only=True）
  - [ ] Metaクラスを定義
  - [ ] model = Syllabusを指定
  - [ ] 全フィールドをfieldsリストに追加（24フィールド + class_schedule）
  - [ ] read_only_fields = ['id']を指定

- [ ] SyllabusCreateSerializerクラスを作成（作成・更新用）
  - [ ] ModelSerializerを継承
  - [ ] class_scheduleフィールドを追加（ClassScheduleCreateSerializer, many=True, required=False）
  - [ ] Metaクラスを定義
  - [ ] model = Syllabusを指定
  - [ ] 全フィールドをfieldsリストに追加（idを除く23フィールド + class_schedule）
  - [ ] validate_academic_yearメソッドを実装（2000～2100の範囲チェック）
  - [ ] createメソッドを実装
    - [ ] class_schedule_dataを取り出し
    - [ ] Syllabusオブジェクトを作成
    - [ ] ClassScheduleオブジェクトを一括作成
    - [ ] Syllabusオブジェクトを返す
  - [ ] updateメソッドを実装
    - [ ] class_schedule_dataを取り出し
    - [ ] Syllabusオブジェクトを更新
    - [ ] 既存のClassScheduleを削除
    - [ ] 新しいClassScheduleを作成
    - [ ] 更新したSyllabusオブジェクトを返す

- [ ] SyllabusPartialUpdateSerializerクラスを作成（部分更新用）
  - [ ] ModelSerializerを継承
  - [ ] Metaクラスを定義
  - [ ] model = Syllabusを指定
  - [ ] 全フィールドをfieldsリストに追加（idとclass_scheduleを除く）
  - [ ] extra_kwargsで全フィールドをrequired=Falseに設定

### 3.4 シリアライザのテスト（任意）

- [ ] Pythonシェルで動作確認
  ```bash
  python manage.py shell
  ```
- [ ] シリアライザのインポートと基本動作を確認

---

## フェーズ4: ビューの実装

### 4.1 viewsファイルの編集

- [ ] `syllabus/views.py`を開く
- [ ] 必要なインポートを追加
  ```python
  from rest_framework import viewsets, status
  from rest_framework.response import Response
  from django.shortcuts import get_object_or_404
  from .models import Syllabus
  from .serializers import (
      SyllabusSerializer,
      SyllabusCreateSerializer,
      SyllabusPartialUpdateSerializer
  )
  ```

### 4.2 SyllabusViewSetの実装

- [ ] SyllabusViewSetクラスを作成
  - [ ] viewsets.ModelViewSetを継承
  - [ ] クラスのdocstringを記述（エンドポイント一覧）

- [ ] querysetを定義
  - [ ] `queryset = Syllabus.objects.all().prefetch_related('class_schedule')`

- [ ] get_serializer_classメソッドを実装
  - [ ] self.actionがcreate/updateの場合: SyllabusCreateSerializerを返す
  - [ ] self.actionがpartial_updateの場合: SyllabusPartialUpdateSerializerを返す
  - [ ] それ以外: SyllabusSerializerを返す

- [ ] listメソッドを実装
  - [ ] querysetを取得
  - [ ] シリアライザで変換
  - [ ] Responseを返す

- [ ] createメソッドを実装
  - [ ] リクエストデータをシリアライザに渡す
  - [ ] バリデーション実行
  - [ ] オブジェクトを作成
  - [ ] 詳細シリアライザで変換してレスポンス（201）

- [ ] retrieveメソッドを実装
  - [ ] オブジェクトを取得
  - [ ] シリアライザで変換
  - [ ] Responseを返す

- [ ] updateメソッドを実装
  - [ ] オブジェクトを取得
  - [ ] リクエストデータをシリアライザに渡す
  - [ ] バリデーション実行
  - [ ] オブジェクトを更新
  - [ ] 詳細シリアライザで変換してレスポンス

- [ ] partial_updateメソッドを実装
  - [ ] オブジェクトを取得
  - [ ] リクエストデータをシリアライザに渡す（partial=True）
  - [ ] バリデーション実行
  - [ ] オブジェクトを更新
  - [ ] 詳細シリアライザで変換してレスポンス

- [ ] destroyメソッドを実装
  - [ ] オブジェクトを取得
  - [ ] オブジェクトを削除
  - [ ] 204レスポンスを返す

---

## フェーズ5: URLルーティングの設定

### 5.1 tutorial/urls.pyの編集

- [ ] `tutorial/urls.py`を開く
- [ ] syllabusビューをインポート
  ```python
  from syllabus import views as syllabus_views
  ```
- [ ] 既存のrouter設定を確認
- [ ] syllabusのルートを登録
  ```python
  router.register(r'syllabi', syllabus_views.SyllabusViewSet, basename='syllabus')
  ```
- [ ] urlpatternsを確認
  - [ ] `path('api/', include(router.urls))`が存在すること
  - [ ] ブラウザブルAPIのログイン用URLが存在すること

### 5.2 URLパターンの確認

- [ ] 開発サーバーを起動
  ```bash
  python manage.py runserver
  ```
- [ ] ブラウザで http://localhost:8000/api/ にアクセス
- [ ] syllabusエンドポイントが表示されることを確認
- [ ] http://localhost:8000/api/syllabi/ にアクセスして空の一覧が表示されることを確認

---

## フェーズ6: 管理画面の設定

### 6.1 admin.pyの編集

- [ ] `syllabus/admin.py`を開く
- [ ] モデルをインポート
  ```python
  from django.contrib import admin
  from .models import Syllabus, ClassSchedule
  ```

### 6.2 ClassScheduleInlineの実装

- [ ] ClassScheduleInlineクラスを作成
  - [ ] admin.TabularInlineを継承
  - [ ] model = ClassScheduleを指定
  - [ ] extra = 1を指定
  - [ ] fieldsを指定: ['order', 'class_hours', 'content']
  - [ ] orderingを指定: ['order']

### 6.3 SyllabusAdminの実装

- [ ] SyllabusAdminクラスを作成
  - [ ] admin.ModelAdminを継承
  - [ ] list_displayを設定
    ```python
    list_display = ['subject_name', 'academic_year', 'semester', 'instructor', 'instructor_type']
    ```
  - [ ] list_filterを設定
    ```python
    list_filter = ['academic_year', 'semester', 'instructor_type', 'course_classification']
    ```
  - [ ] search_fieldsを設定
    ```python
    search_fields = ['subject_name', 'instructor', 'course_overview']
    ```
  - [ ] inlinesを設定
    ```python
    inlines = [ClassScheduleInline]
    ```
  - [ ] fieldsets（任意）でフィールドをグループ化

### 6.4 モデルの登録

- [ ] Syllabusモデルを登録
  ```python
  admin.site.register(Syllabus, SyllabusAdmin)
  ```

### 6.5 管理画面の動作確認

- [ ] 管理者ユーザーを作成（未作成の場合）
  ```bash
  python manage.py createsuperuser
  ```
- [ ] http://localhost:8000/admin/ にアクセス
- [ ] ログイン
- [ ] シラバスセクションが表示されることを確認
- [ ] シラバス一覧画面の動作確認
- [ ] シラバス追加画面の動作確認
- [ ] コマシラバスのインライン表示を確認

---

## フェーズ7: API動作確認とテスト

### 7.1 サンプルデータの作成

- [ ] 管理画面またはAPIから最初のシラバスを作成
- [ ] 以下の項目を含むテストデータを用意
  - [ ] 科目名: "Python応用(Django)②"
  - [ ] 開講年度: 2025
  - [ ] 学期: "後期"
  - [ ] 担当教員: "鈴木亮"
  - [ ] コマシラバス: 最低2件

### 7.2 GET /api/syllabi/ のテスト

- [ ] ブラウザまたはcurlで一覧取得
  ```bash
  curl http://localhost:8000/api/syllabi/
  ```
- [ ] レスポンスが正常に返ることを確認
- [ ] class_scheduleが含まれていることを確認

### 7.3 POST /api/syllabi/ のテスト

- [ ] curlまたはPostmanで新規作成をテスト
  ```bash
  curl -X POST http://localhost:8000/api/syllabi/ \
    -H "Content-Type: application/json" \
    -d '{
      "subject_name": "テスト科目",
      "academic_year": 2025,
      "class_schedule": [
        {"order": 1, "class_hours": 2, "content": "第1回の内容"}
      ]
    }'
  ```
- [ ] 201ステータスが返ることを確認
- [ ] 作成されたデータが返ることを確認
- [ ] class_scheduleも一緒に作成されることを確認

### 7.4 GET /api/syllabi/{id}/ のテスト

- [ ] 特定のIDで詳細取得
  ```bash
  curl http://localhost:8000/api/syllabi/1/
  ```
- [ ] 200ステータスが返ることを確認
- [ ] 全フィールドが返ることを確認

### 7.5 PUT /api/syllabi/{id}/ のテスト

- [ ] 全更新をテスト
  ```bash
  curl -X PUT http://localhost:8000/api/syllabi/1/ \
    -H "Content-Type: application/json" \
    -d '{
      "subject_name": "更新後の科目名",
      "academic_year": 2025
    }'
  ```
- [ ] 200ステータスが返ることを確認
- [ ] 更新されたデータが返ることを確認

### 7.6 PATCH /api/syllabi/{id}/ のテスト

- [ ] 部分更新をテスト
  ```bash
  curl -X PATCH http://localhost:8000/api/syllabi/1/ \
    -H "Content-Type: application/json" \
    -d '{"instructor": "田中太郎"}'
  ```
- [ ] 200ステータスが返ることを確認
- [ ] 指定したフィールドのみ更新されることを確認

### 7.7 DELETE /api/syllabi/{id}/ のテスト

- [ ] 削除をテスト
  ```bash
  curl -X DELETE http://localhost:8000/api/syllabi/2/
  ```
- [ ] 204ステータスが返ることを確認
- [ ] 削除されたことを確認（GETで404になる）

### 7.8 エラーケースのテスト

- [ ] 必須フィールドなしでPOST → 400エラー
- [ ] 存在しないIDでGET → 404エラー
- [ ] 無効なデータ型でPOST → 400エラー
- [ ] 範囲外のacademic_yearでPOST → 400エラー

### 7.9 バリデーションのテスト

- [ ] class_hoursが0以下でエラーになることを確認
- [ ] orderが0以下でエラーになることを確認
- [ ] academic_yearが範囲外でエラーになることを確認

---

## フェーズ8: 自動テストの作成

### 8.1 モデルのテスト

- [ ] `syllabus/tests.py`を開く
- [ ] 必要なインポートを追加
  ```python
  from django.test import TestCase
  from .models import Syllabus, ClassSchedule
  ```

- [ ] SyllabusModelTestクラスを作成
  - [ ] setUpメソッドでテストデータを作成
  - [ ] test_syllabus_creation: モデル作成のテスト
  - [ ] test_syllabus_str: __str__メソッドのテスト
  - [ ] test_syllabus_ordering: orderingのテスト

- [ ] ClassScheduleModelTestクラスを作成
  - [ ] setUpメソッドでテストデータを作成
  - [ ] test_class_schedule_creation: モデル作成のテスト
  - [ ] test_class_schedule_str: __str__メソッドのテスト
  - [ ] test_unique_together: unique_together制約のテスト

### 8.2 シリアライザのテスト

- [ ] SyllabusSerializerTestクラスを作成
  - [ ] test_serializer_with_valid_data: 有効なデータのテスト
  - [ ] test_serializer_with_invalid_data: 無効なデータのテスト
  - [ ] test_academic_year_validation: 年度バリデーションのテスト

### 8.3 APIエンドポイントのテスト

- [ ] rest_framework.testをインポート
  ```python
  from rest_framework.test import APITestCase
  from rest_framework import status
  ```

- [ ] SyllabusAPITestクラスを作成
  - [ ] setUpメソッドでテストデータとクライアントを準備
  - [ ] test_get_syllabus_list: 一覧取得のテスト
  - [ ] test_create_syllabus: 作成のテスト
  - [ ] test_get_syllabus_detail: 詳細取得のテスト
  - [ ] test_update_syllabus: 更新のテスト
  - [ ] test_partial_update_syllabus: 部分更新のテスト
  - [ ] test_delete_syllabus: 削除のテスト
  - [ ] test_create_syllabus_with_class_schedule: コマシラバス付き作成のテスト

### 8.4 テストの実行

- [ ] すべてのテストを実行
  ```bash
  python manage.py test syllabus
  ```
- [ ] すべてのテストがパスすることを確認
- [ ] カバレッジレポートの確認（任意）

---

## フェーズ9: OpenAPI仕様との整合性確認

### 9.1 レスポンス形式の確認

- [ ] openapi.yamlを開く
- [ ] GET /api/syllabi/ のレスポンスが仕様通りか確認
- [ ] POST /api/syllabi/ のリクエスト/レスポンスが仕様通りか確認
- [ ] GET /api/syllabi/{id}/ のレスポンスが仕様通りか確認
- [ ] PUT /api/syllabi/{id}/ のリクエスト/レスポンスが仕様通りか確認
- [ ] PATCH /api/syllabi/{id}/ のリクエスト/レスポンスが仕様通りか確認
- [ ] DELETE /api/syllabi/{id}/ のレスポンスが仕様通りか確認

### 9.2 ステータスコードの確認

- [ ] 200 OK: 取得・更新成功
- [ ] 201 Created: 作成成功
- [ ] 204 No Content: 削除成功
- [ ] 400 Bad Request: 無効なリクエスト
- [ ] 404 Not Found: リソースが見つからない

### 9.3 スキーマの確認

- [ ] Syllabusスキーマの全フィールドが実装されているか確認
- [ ] SyllabusCreateスキーマの全フィールドが実装されているか確認
- [ ] SyllabusPartialUpdateスキーマの全フィールドが実装されているか確認
- [ ] ClassScheduleスキーマの全フィールドが実装されているか確認
- [ ] ClassScheduleCreateスキーマの全フィールドが実装されているか確認

### 9.4 必須フィールドの確認

- [ ] subject_nameが必須であることを確認
- [ ] academic_yearが必須であることを確認
- [ ] class_schedule内のorder, class_hours, contentが必須であることを確認

---

## フェーズ10: ドキュメント更新と最終確認

### 10.1 READMEの更新

- [ ] README.mdを開く
- [ ] プロジェクト概要を記載
- [ ] セットアップ手順を記載
- [ ] API使用例を記載
- [ ] 開発サーバーの起動方法を記載

### 10.2 API仕様書の確認

- [ ] docs/index.htmlが存在することを確認
- [ ] ブラウザでAPI仕様書を表示して内容を確認
- [ ] 実装と仕様書が一致していることを確認

### 10.3 コードレビュー

- [ ] models.pyのコードを見直し
  - [ ] フィールド定義が正しいか
  - [ ] verbose_nameが適切か
  - [ ] Metaクラスが適切か
- [ ] serializers.pyのコードを見直し
  - [ ] シリアライザの使い分けが適切か
  - [ ] バリデーションが十分か
  - [ ] create/updateメソッドが正しく動作するか
- [ ] views.pyのコードを見直し
  - [ ] 各アクションが適切に実装されているか
  - [ ] エラーハンドリングが適切か
- [ ] admin.pyのコードを見直し
  - [ ] 管理画面の使いやすさ

### 10.4 パフォーマンスチェック

- [ ] N+1問題が発生していないか確認（prefetch_related使用）
- [ ] 大量データでの動作確認（任意）
- [ ] ページネーションが機能することを確認

### 10.5 セキュリティチェック

- [ ] SQLインジェクション対策（ORM使用で対応済み）
- [ ] XSS対策（DRFで自動エスケープ）
- [ ] 入力バリデーション（シリアライザで実装済み）
- [ ] SECRET_KEYが環境変数化されているか（本番環境）

---

## フェーズ11: Git管理

### 11.1 変更のコミット

- [ ] 変更ファイルを確認
  ```bash
  git status
  ```
- [ ] 実装ファイルをステージング
  ```bash
  git add syllabus/
  git add tutorial/settings.py
  git add tutorial/urls.py
  git add docs/
  ```
- [ ] コミット
  ```bash
  git commit -m "シラバスAPIの実装を完了

  - Syllabus, ClassScheduleモデルの実装
  - シリアライザの実装（読み取り/作成/更新用）
  - SyllabusViewSetの実装
  - 管理画面の設定
  - APIテストの実装
  - OpenAPI仕様に準拠"
  ```

### 11.2 ブランチの確認

- [ ] 現在のブランチを確認
  ```bash
  git branch
  ```
- [ ] 必要に応じてブランチをマージまたはPRを作成

---

## 完了チェックリスト

最終確認項目：

- [ ] 全てのAPIエンドポイントが正常に動作する
- [ ] テストが全てパスする
- [ ] OpenAPI仕様と実装が一致している
- [ ] 管理画面が正常に動作する
- [ ] ドキュメントが最新の状態である
- [ ] コードが適切にコミットされている
- [ ] 開発環境で問題なく動作する

---

## 次のステップ（任意・将来の拡張）

実装完了後、以下の機能追加を検討：

- [ ] 認証機能の追加（JWT等）
- [ ] パーミッション設定
- [ ] フィルタリング機能（django-filter）
- [ ] 検索機能
- [ ] PDF/CSVエクスポート
- [ ] バージョン管理機能
- [ ] キャッシング機能
- [ ] Docker化
- [ ] CI/CD設定

---

**作成日**: 2025-11-12
**バージョン**: 1.0
**対応設計書**: docs/design.md
