# DevOps Курсова Робота

Цей проект демонструє DevOps практики із використанням:
- Python Flask додатку
- Docker контейнеризації
- Terraform для інфраструктури
- AWS Lambda для безсерверного розгортання
- CI/CD з GitHub Actions
- Моніторинг з Prometheus, Grafana та Loki

## Структура проекту

```
devops-cursova/
├── app.py                    # Flask додаток з підтримкою AWS Lambda та Prometheus метрик
├── Dockerfile                # Конфігурація Docker образу
├── .dockerignore             # Ігноровані Docker файли
├── requirements.txt          # Python залежності
├── terraform/                # Terraform конфігурація
│   ├── aws/                  # AWS Lambda конфігурація
│   │   ├── main.tf           # Основна Terraform конфігурація для AWS
│   │   ├── variables.tf      # Змінні для AWS конфігурації
│   │   └── outputs.tf        # Виводи AWS конфігурації
│   └── local/                # Локальна Terraform конфігурація
│       ├── main.tf           # Основна Terraform конфігурація для локального розгортання
│       └── outputs.tf        # Terraform виводи для локального розгортання
├── k8s-manifests/            # Kubernetes маніфести для локального розгортання
│   ├── app/                  # Маніфести для додатку
│   │   ├── deployment.yaml   # Конфігурація розгортання додатку
│   │   ├── service.yaml      # Конфігурація сервісу додатку
│   │   └── namespace.yaml    # Конфігурація namespace для додатку
│   └── monitoring/           # Маніфести для системи моніторингу
│       ├── prometheus-*.yaml # Конфігурації Prometheus
│       ├── grafana-*.yaml    # Конфігурації Grafana
│       ├── loki-*.yaml       # Конфігурації Loki
│       └── promtail-*.yaml   # Конфігурації Promtail
├── .github/                  # GitHub Workflows
│   └── workflows/
│       ├── ci.yml            # CI конфігурація
│       └── aws-deploy.yml    # AWS деплой конфігурація
└── tests/                    # Тести
    └── test_app.py           # Тести для Flask додатку
```

## Вимоги

### Для локального розгортання
- Docker Desktop
- Minikube
- kubectl
- Terraform
- Python 3.9+

### Для розгортання на AWS
- AWS акаунт з Free Tier доступом
- AWS CLI
- Terraform
- Python 3.9+

## AWS Lambda розгортання

Проект налаштований для безсерверного розгортання на AWS Lambda з використанням безкоштовного рівня (Free Tier). Це дозволяє запускати додаток без постійно працюючих серверів, оплачуючи лише за фактичне використання ресурсів.

### Переваги AWS Lambda для цього проекту:

1. **Безкоштовний рівень**: AWS Lambda Free Tier включає 1 мільйон безкоштовних запитів на місяць і 400 000 ГБ-секунд обчислювального часу.
2. **Масштабування**: Автоматичне масштабування відповідно до навантаження.
3. **Економія**: Оплата лише за фактичний час виконання коду.
4. **Інтеграція з API Gateway**: Створення повноцінного API для доступу до додатку.

### CloudWatch моніторинг

Для моніторингу AWS Lambda використовується CloudWatch. Наша конфігурація оптимізована для безкоштовного рівня:

#### Логування в CloudWatch
- **Автоматичне логування**: Lambda функція автоматично записує логи в CloudWatch Logs
- **Формат логів**: Кожен запит до API Gateway логується з деталями події
- **Період зберігання**: Встановлено 3 дні для оптимізації використання безкоштовного ліміту 5 ГБ

#### Метрики в CloudWatch
- **Lambda метрики**: Errors, Throttles, Duration, Invocations
- **API Gateway метрики**: Latency, Count, 4XXError, 5XXError
- **Використання безкоштовних метрик**: Оптимізовано для 10 безкоштовних метрик CloudWatch

#### Аларми CloudWatch
- **Помилки Lambda**: Сповіщення при перевищенні порогу помилок
- **Тривалість виконання**: Сповіщення при перевищенні середнього часу виконання
- **Обмеження API Gateway**: Сповіщення про обмеження запитів

### Налаштування AWS облікового запису

1. Створіть обліковий запис AWS: https://aws.amazon.com/free/
2. Створіть користувача IAM з правами доступу до Lambda, API Gateway, S3, CloudWatch та IAM.
3. Згенеруйте ключі доступу (Access Key ID і Secret Access Key).
4. Додайте ключі як секрети у ваш GitHub репозиторій:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY

### Ручне розгортання на AWS

```bash
# Налаштування AWS CLI
aws configure

# Ініціалізація та застосування Terraform конфігурації
cd terraform/aws
terraform init
terraform apply -auto-approve

# Перегляд URL API Gateway
terraform output api_gateway_url
```

### Автоматичне розгортання через GitHub Actions

Проект налаштований для автоматичного розгортання на AWS Lambda при кожному пуші в гілку main. GitHub Actions виконує наступні кроки:

1. Запуск тестів
2. Ініціалізація Terraform
3. Розгортання інфраструктури на AWS
4. Виведення URL API Gateway

## Локальне розгортання

### 1. Встановлення необхідних інструментів

```powershell
# Через winget (Windows)
winget install Docker.DockerDesktop
winget install Kubernetes.minikube
winget install Kubernetes.kubectl
winget install HashiCorp.Terraform
winget install Python.Python.3.9
```

### 2. Запуск Docker

Запустіть Docker Desktop і дочекайтеся його повного запуску.

### 3. Запуск Minikube

```powershell
minikube start
```

### 4. Розгортання Docker контейнера з Terraform

```powershell
cd terraform/local
terraform init
terraform apply -auto-approve
```

### 5. Розгортання в Kubernetes

```powershell
# Налаштування Minikube для локальних образів
minikube docker-env --shell powershell | Invoke-Expression

# Збірка Docker образу
docker build -t python-app:latest .

# Створення namespace
kubectl apply -f k8s-manifests/app/namespace.yaml
kubectl apply -f k8s-manifests/monitoring/namespace.yaml

# Розгортання додатку
kubectl apply -f k8s-manifests/app/deployment.yaml
kubectl apply -f k8s-manifests/app/service.yaml

# Розгортання системи моніторингу
kubectl apply -f k8s-manifests/monitoring/prometheus-config.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-server-pv.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-server-pvc.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-service.yaml

kubectl apply -f k8s-manifests/monitoring/grafana-datasource.yaml
kubectl apply -f k8s-manifests/monitoring/grafana-deployment.yaml
kubectl apply -f k8s-manifests/monitoring/grafana-service.yaml

kubectl apply -f k8s-manifests/monitoring/loki-config.yaml
kubectl apply -f k8s-manifests/monitoring/loki-deployment.yaml
kubectl apply -f k8s-manifests/monitoring/loki-service.yaml

kubectl apply -f k8s-manifests/monitoring/promtail-rbac.yaml
kubectl apply -f k8s-manifests/monitoring/promtail-configmap.yaml
kubectl apply -f k8s-manifests/monitoring/promtail-daemonset.yaml

# Перевірка статусу
kubectl get pods -n monitoring
kubectl get pods -n python-app

# Відкриття додатку в браузері
minikube service python-app -n python-app
```

## Розробка

1. Створіть віртуальне середовище Python:
```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

2. Внесіть зміни в код
3. Запустіть тести: `pytest`
4. Для локального тестування AWS Lambda функціональності:
```powershell
pip install python-lambda-local
python-lambda-local -f lambda_handler app.py event.json
```

## Моніторинг

### Локальний стек моніторингу

Проект використовує повний стек моніторингу для локального розгортання:

1. **Prometheus** - збір та зберігання метрик
   - Конфігурація: `k8s-manifests/monitoring/prometheus-config.yaml`
   - Зберігання даних: `prometheus-server-pv.yaml` та `prometheus-server-pvc.yaml`
   - Розгортання: `prometheus-deployment.yaml` та `prometheus-service.yaml`

2. **Grafana** - візуалізація метрик та логів
   - Джерела даних: `grafana-datasource.yaml` (Prometheus та Loki)
   - Розгортання: `grafana-deployment.yaml` та `grafana-service.yaml`
   - Доступ: http://localhost:3000 (після port-forward)
   - Логін: admin / Пароль: admin

3. **Loki** - агрегація та зберігання логів
   - Конфігурація: `loki-config.yaml`
   - Розгортання: `loki-deployment.yaml` та `loki-service.yaml`

4. **Promtail** - збір логів з контейнерів
   - Конфігурація: `promtail-configmap.yaml`
   - Права доступу: `promtail-rbac.yaml`
   - Розгортання: `promtail-daemonset.yaml`

#### Метрики додатку

Додаток надає наступні метрики через ендпоінт `/metrics`:

1. `app_request_count` - лічильник запитів за методом, ендпоінтом та статусом
2. `app_request_latency_seconds` - гістограма часу відповіді за методом та ендпоінтом

#### Доступ до інструментів моніторингу

```powershell
# Prometheus (метрики)
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring

# Grafana (дашборди та логи)
kubectl port-forward svc/grafana 3000:3000 -n monitoring
```

#### Перегляд логів у Grafana

1. Відкрийте Grafana: http://localhost:3000
2. Увійдіть з обліковими даними: admin / admin
3. Перейдіть до розділу "Explore"
4. Виберіть джерело даних "Loki"
5. Використовуйте запит: `{namespace="python-app"}`

### AWS CloudWatch моніторинг

Для перегляду логів та метрик у AWS CloudWatch:

1. **Перегляд логів**: 
   - AWS консоль > CloudWatch > Log groups > /aws/lambda/python-app
   - Фільтрація логів: Використовуйте CloudWatch Logs Insights для аналізу

2. **Перегляд метрик**:
   - AWS консоль > CloudWatch > Metrics > Lambda > By Function Name
   - Доступні метрики: Errors, Throttles, Duration, Invocations

3. **Налаштування алармів**:
   - AWS консоль > CloudWatch > Alarms
   - Створення нових алармів: "Create alarm" > "Select metric"

4. **Оптимізація Free Tier**:
   - Використовуйте не більше 10 метрик
   - Створюйте не більше 10 алармів
   - Обмежте період зберігання логів до 3-7 днів

# Технічна документація

Детальну технічну документацію можна знайти на [TOYE-devops-project](https://github.com/OluwaTossin/TOYE-devops-project/wiki)
