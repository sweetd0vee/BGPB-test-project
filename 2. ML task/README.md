Цель задачи построить модель, предсказывающую вероятность дефолта клиента - **Маркер**. Так как мы имеем дело с бинарной классификацией, то для оценки точности модели использовалась такая метрика как **roc_auc**.


### Установка зависимостей:

``python -m venv venv``

``source venv/bin/activate``

``pip install -r requirements.txt``

### Запуск локально:


``uvicorn app:app --reload``


### Запуск в docker:


``cd docker``

``./docker-build.sh`` - создать docker image

``docker run -p 8000:8000 arina/bgps:master``


### Или через docker compose:


``./docker-build.sh``

``./docker-compose-up.sh`` - запустить контейнер
