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
│   ├── deployment.yaml       # Конфігурація розгортання
│   ├── service.yaml          # Конфігурація сервісу
│   ├── namespace.yaml        # Конфігурація namespace для моніторингу
│   ├── prometheus-*.yaml     # Конфігурація Prometheus
│   ├── grafana-*.yaml        # Конфігурація Grafana
│   ├── loki-*.yaml           # Конфігурація Loki
│   └── promtail-*.yaml       # Конфігурація Promtail
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

### CloudWatch Free Tier та моніторинг

Проект оптимізовано для максимального використання безкоштовних лімітів CloudWatch:

#### Ліміти Free Tier CloudWatch:
1. **Логи (CloudWatch Logs)**:
   - 5 ГБ даних щомісяця (включно з інжестом, архівним зберіганням і даними, просканованими Log Insights-запитами)
   - 1 800 хвилин Live Tail (приблизно 1 година "живої" стрічки на добу)

2. **Метрики (Metrics)**:
   - 10 безкоштовних метрик (Custom Metrics або Detailed Monitoring)
   - 1 000 000 API-запитів до CloudWatch Metrics щомісяця

3. **Дашборди (Dashboards)**:
   - 3 Custom Dashboards (до 50 метрик у кожному)
   - Усі автоматичні дашборди — безлімітні й безкоштовні

4. **Аларми (Alarms)**:
   - 10 Alarm metrics стандартної роздільної здатності

#### Наша конфігурація CloudWatch:
- **Логи**: Період зберігання логів встановлено на 3 дні для оптимізації використання 5 ГБ безкоштовного ліміту
- **Метрики**: Налаштовано основні метрики для Lambda (Errors, Throttles, Duration) та API Gateway
- **Дашборд**: Створено один дашборд з ключовими метриками (залишається ще 2 безкоштовних)
- **Аларми**: Налаштовано 3 аларми для моніторингу помилок, обмежень та тривалості виконання Lambda функції

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

# Створення namespace для моніторингу
kubectl apply -f k8s-manifests/namespace.yaml

# Розгортання додатку
kubectl apply -f k8s-manifests/deployment.yaml
kubectl apply -f k8s-manifests/service.yaml

# Розгортання системи моніторингу
kubectl apply -f k8s-manifests/prometheus-config.yaml
kubectl apply -f k8s-manifests/prometheus-server-pv.yaml
kubectl apply -f k8s-manifests/prometheus-server-pvc.yaml
kubectl apply -f k8s-manifests/prometheus-deployment.yaml
kubectl apply -f k8s-manifests/prometheus-service.yaml

kubectl apply -f k8s-manifests/grafana-datasource.yaml
kubectl apply -f k8s-manifests/grafana-deployment.yaml
kubectl apply -f k8s-manifests/grafana-service.yaml

kubectl apply -f k8s-manifests/loki-config.yaml
kubectl apply -f k8s-manifests/loki-deployment.yaml
kubectl apply -f k8s-manifests/loki-service.yaml

kubectl apply -f k8s-manifests/promtail-rbac.yaml
kubectl apply -f k8s-manifests/promtail-configmap.yaml
kubectl apply -f k8s-manifests/promtail-daemonset.yaml

# Перевірка статусу
kubectl get pods -n monitoring
kubectl get pods

# Відкриття додатку в браузері
minikube service python-app
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

### Локальний моніторинг

Проект використовує стек моніторингу, що складається з:

1. **Prometheus** - для збору та зберігання метрик
2. **Grafana** - для візуалізації метрик
3. **Loki** - для збору та зберігання логів
4. **Promtail** - для збору логів з контейнерів

#### Доступ до інструментів моніторингу

```powershell
# Prometheus (метрики)
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring

# Grafana (дашборди)
kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Логін: admin
# Пароль: admin
```

#### Метрики додатку

Додаток надає наступні метрики через ендпоінт `/metrics`:

1. `app_request_count` - лічильник запитів за методом, ендпоінтом та статусом
2. `app_request_latency_seconds` - гістограма часу відповіді за методом та ендпоінтом

#### Логування

Логи додатку збираються Promtail та зберігаються в Loki. Вони доступні через Grafana в розділі "Explore".

### AWS моніторинг
Для моніторингу AWS Lambda використовується CloudWatch. Проект налаштовано з урахуванням обмежень безкоштовного рівня CloudWatch:

1. **Перегляд логів**: 
   - AWS консоль > CloudWatch > Log groups > /aws/lambda/python-app
   - Період зберігання: 3 дні для оптимізації використання 5 ГБ безкоштовного ліміту

2. **Дашборд**:
   - AWS консоль > CloudWatch > Dashboards > python-app-dashboard
   - Містить ключові метрики Lambda функції та API Gateway

3. **Аларми**:
   - Налаштовано аларми для моніторингу помилок, обмежень та тривалості виконання
   - Переглянути можна в AWS консолі > CloudWatch > Alarms

4. **Оптимізація використання Free Tier**:
   - Використано лише 3 з 10 доступних безкоштовних алармів
   - Створено 1 з 3 доступних безкоштовних дашбордів
   - Налаштовано короткий період зберігання логів для економії місця

# Технічна документація

Детальну технічну документацію можна знайти на [TOYE-devops-project](https://github.com/OluwaTossin/TOYE-devops-project/wiki)
