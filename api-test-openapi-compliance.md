# OpenAPI仕様準拠テスト結果

テスト実施日時: 2025-12-17 11:49:51
ベースURL: http://localhost:8000


## Test #1: シラバス一覧取得

**リクエスト:**
```
GET /api/syllabi/
```

**期待ステータス:** 200
**実際のステータス:** 200
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "subject_name": "Python\u5fdc\u7528(Django)\u2461",
            "regulation_subject_name": "\u30b7\u30b9\u30c6\u30e0\u958b\u767a\u6f14\u7fd2",
            "teacher_name": "\u9234\u6728\u4eae",
            "instructor_type": "\u5b9f\u52d9\u6559\u54e1",
            "teaching_method": "\u8b1b\u7fa9&\u6f14\u7fd2",
            "num_sessions": 30,
            "recommended_grade": "2\u5e74\uff5e",
            "enrollment_classification": "\u5fc5\u4fee\u9078\u629e",
            "academic_year": 2025,
            "semester": "\u5f8c\u671f",
            "eligible_departments": [
                "\u9ad8\u5ea6\u60c5\u5831\u5de5\u5b66\u79d1",
                "\u7dcf\u5408\u30b7\u30b9\u30c6\u30e0\u5de5\u5b66\u79d1",
```

## Test #2: シラバス詳細取得（ID=1）

**リクエスト:**
```
GET /api/syllabi/1/
```

**期待ステータス:** 200
**実際のステータス:** 200
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "id": 1,
    "subject_name": "Python\u5fdc\u7528(Django)\u2461",
    "regulation_subject_name": "\u30b7\u30b9\u30c6\u30e0\u958b\u767a\u6f14\u7fd2",
    "teacher_name": "\u9234\u6728\u4eae",
    "instructor_type": "\u5b9f\u52d9\u6559\u54e1",
    "teaching_method": "\u8b1b\u7fa9&\u6f14\u7fd2",
    "num_sessions": 30,
    "recommended_grade": "2\u5e74\uff5e",
    "enrollment_classification": "\u5fc5\u4fee\u9078\u629e",
    "academic_year": 2025,
    "semester": "\u5f8c\u671f",
    "eligible_departments": [
        "\u9ad8\u5ea6\u60c5\u5831\u5de5\u5b66\u79d1",
        "\u7dcf\u5408\u30b7\u30b9\u30c6\u30e0\u5de5\u5b66\u79d1",
        "\u60c5\u5831\u30b7\u30b9\u30c6\u30e0\u79d1"
    ],
    "course_overview": "\u307e\u305aDjango \u3067 RESTful API \u304c\u4f5c\u308c\u308b\u3053\u3068\u3002\u6b21\u306bDjango \u4ee5\u5916\u306e\u30d5\u30ec\u30fc\u30e0\u30ef\u30fc\u30af\u3067\u3082 RESTful API \u3092\u69cb\u7bc9\u3067\u304d\u308b\u3053\u3068\u3002",
    "learning_objectives": "RESTful \u306e\u6982\u5ff5\u3092\u7406\u89e3\u3059\u308b\u3053\u3068\u3002RESTful API \u306e\u4ed5\u69d8\u3092\u5b9a\u7fa9\u3067\u304d\u308b\u3053\u3068\u3002Django \u3067 RESTful API \u304c\u4f5c\u308c\u308b\u3053\u3068\u3002RESTful API\u306e\u30c6\u30b9\u30c8\u3092\u66f8\u3051\u308b\u3053\u3068\u3002",
    "grading_prerequisites": "\u51fa\u5e2d\u7387\u304c80%\u4ee5\u4e0a\u3067\u3042\u308b\u3053\u3068\u3001\u304a\u3088\u3073\u3001\u5404\u8a55\u4fa1\u9805\u76ee\u304c\u3059\u3079\u3066\u300c\u53ef\u300d\u4ee5\u4e0a\u3067\u3042\u308b\u3053\u3068",
```

## Test #3: シラバス詳細取得（存在しないID=999）

**リクエスト:**
```
GET /api/syllabi/999/
```

**期待ステータス:** 404
**実際のステータス:** 404
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "detail": "No Syllabus matches the given query."
}
```

## Test #4: シラバス作成（認証なし）- 401期待

**リクエスト:**
```
POST /api/syllabi/
```

**期待ステータス:** 401
**実際のステータス:** 000
**結果:** ❌ FAIL

**レスポンス概要:**
```json
```

## Test #5: シラバス更新（認証なし）- 401期待

**リクエスト:**
```
PUT /api/syllabi/1/
```

**期待ステータス:** 401
**実際のステータス:** 000
**結果:** ❌ FAIL

**レスポンス概要:**
```json
```

## Test #6: シラバス削除（認証なし）- 401期待

**リクエスト:**
```
DELETE /api/syllabi/1/
```

**期待ステータス:** 401
**実際のステータス:** 401
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "detail": "Authentication credentials were not provided."
}
```

## Test #7: フィルタリング: academic_year=2025

**リクエスト:**
```
GET /api/syllabi/?academic_year=2025
```

**期待ステータス:** 200
**実際のステータス:** 200
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "subject_name": "Python\u5fdc\u7528(Django)\u2461",
            "regulation_subject_name": "\u30b7\u30b9\u30c6\u30e0\u958b\u767a\u6f14\u7fd2",
            "teacher_name": "\u9234\u6728\u4eae",
            "instructor_type": "\u5b9f\u52d9\u6559\u54e1",
            "teaching_method": "\u8b1b\u7fa9&\u6f14\u7fd2",
            "num_sessions": 30,
            "recommended_grade": "2\u5e74\uff5e",
            "enrollment_classification": "\u5fc5\u4fee\u9078\u629e",
            "academic_year": 2025,
            "semester": "\u5f8c\u671f",
            "eligible_departments": [
                "\u9ad8\u5ea6\u60c5\u5831\u5de5\u5b66\u79d1",
                "\u7dcf\u5408\u30b7\u30b9\u30c6\u30e0\u5de5\u5b66\u79d1",
```

## Test #8: フィルタリング: semester=後期

**リクエスト:**
```
GET /api/syllabi/?semester=後期
```

**期待ステータス:** 200
**実際のステータス:** 200
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "subject_name": "Python\u5fdc\u7528(Django)\u2461",
            "regulation_subject_name": "\u30b7\u30b9\u30c6\u30e0\u958b\u767a\u6f14\u7fd2",
            "teacher_name": "\u9234\u6728\u4eae",
            "instructor_type": "\u5b9f\u52d9\u6559\u54e1",
            "teaching_method": "\u8b1b\u7fa9&\u6f14\u7fd2",
            "num_sessions": 30,
            "recommended_grade": "2\u5e74\uff5e",
            "enrollment_classification": "\u5fc5\u4fee\u9078\u629e",
            "academic_year": 2025,
            "semester": "\u5f8c\u671f",
            "eligible_departments": [
                "\u9ad8\u5ea6\u60c5\u5831\u5de5\u5b66\u79d1",
                "\u7dcf\u5408\u30b7\u30b9\u30c6\u30e0\u5de5\u5b66\u79d1",
```

## Test #9: 検索: search=Django

**リクエスト:**
```
GET /api/syllabi/?search=Django
```

**期待ステータス:** 200
**実際のステータス:** 200
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "subject_name": "Python\u5fdc\u7528(Django)\u2461",
            "regulation_subject_name": "\u30b7\u30b9\u30c6\u30e0\u958b\u767a\u6f14\u7fd2",
            "teacher_name": "\u9234\u6728\u4eae",
            "instructor_type": "\u5b9f\u52d9\u6559\u54e1",
            "teaching_method": "\u8b1b\u7fa9&\u6f14\u7fd2",
            "num_sessions": 30,
            "recommended_grade": "2\u5e74\uff5e",
            "enrollment_classification": "\u5fc5\u4fee\u9078\u629e",
            "academic_year": 2025,
            "semester": "\u5f8c\u671f",
            "eligible_departments": [
                "\u9ad8\u5ea6\u60c5\u5831\u5de5\u5b66\u79d1",
                "\u7dcf\u5408\u30b7\u30b9\u30c6\u30e0\u5de5\u5b66\u79d1",
```

## Test #10: ページネーション: page=1

**リクエスト:**
```
GET /api/syllabi/?page=1
```

**期待ステータス:** 200
**実際のステータス:** 200
**結果:** ✅ PASS

**レスポンス概要:**
```json
{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "subject_name": "Python\u5fdc\u7528(Django)\u2461",
            "regulation_subject_name": "\u30b7\u30b9\u30c6\u30e0\u958b\u767a\u6f14\u7fd2",
            "teacher_name": "\u9234\u6728\u4eae",
            "instructor_type": "\u5b9f\u52d9\u6559\u54e1",
            "teaching_method": "\u8b1b\u7fa9&\u6f14\u7fd2",
            "num_sessions": 30,
            "recommended_grade": "2\u5e74\uff5e",
            "enrollment_classification": "\u5fc5\u4fee\u9078\u629e",
            "academic_year": 2025,
            "semester": "\u5f8c\u671f",
            "eligible_departments": [
                "\u9ad8\u5ea6\u60c5\u5831\u5de5\u5b66\u79d1",
                "\u7dcf\u5408\u30b7\u30b9\u30c6\u30e0\u5de5\u5b66\u79d1",
```

## テスト結果サマリー

- 総テスト数: 10
- ✅ 成功: 8
- ❌ 失敗: 2

**結果: ❌ 一部のテストが失敗**
