FROM python:3.9.22-slim-bullseye

RUN pip install jupyterlab psycopg2-binary numpy pandas matplotlib scikit-learn

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token=8b3a6b5a9d9b2c9e3c12d7e1a2f5b8a7f9d4e1c3b2a9f0e3d6c5b7a8c3e9d2f0
