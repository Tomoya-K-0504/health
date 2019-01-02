# 環境構築

### 関連するすべてのdockerを立ち上げる
docker-compose up -d

#### 初期データを投入する
python manage.py loaddata api_health/fixtures/DataSources.json


### 試しにデータを入れてみる
```
curl http://35.236.167.20/api/accel/ -X POST -H "Content-Type: application/json" -d "[{\"data_source\": \"iphone 8\", \"values\": {\"x\": 0.021, \"y\": 0.00213, \"z\": 0.00234}}]"
```
djangoのshellに入る
```
docker-compose exec web python manage.py shell
```
shell内で
```
>>> from api_health.models import Acceleration
>>> Acceleration.objects.all()
```
返り値が`<QuerySet [<Acceleration: Acceleration object (1)>]>`のようになればOK.


#### 開発時メモ
マイグレーションファイル作成
```
python manage.py makemigrations api_health
```
マイグレーション
```
python manage.py migrate
```