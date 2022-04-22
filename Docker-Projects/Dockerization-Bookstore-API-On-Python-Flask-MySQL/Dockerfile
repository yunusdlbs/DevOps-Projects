FROM python:alpine
COPY . /myapp
WORKDIR /myapp
RUN pip install -r requirements.txt
EXPOSE 80
CMD python ./bookstore-api.py