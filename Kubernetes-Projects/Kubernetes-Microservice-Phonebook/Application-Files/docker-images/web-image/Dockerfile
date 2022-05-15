FROM python:alpine
COPY . /app
RUN pip3 install flask
RUN pip3 install flask-mysql
# RUN pip install -r requirements.txt
WORKDIR /app
EXPOSE 80
CMD python ./app.py