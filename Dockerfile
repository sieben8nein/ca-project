FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y python3-pip python3-dev build-essential

COPY requirements.txt /usr/src/app/

RUN pip3 install -r /usr/src/app/requirements.txt

COPY . /usr/src/app/

EXPOSE 5000

CMD ["python3", "/usr/src/app/run.py"]