## Docker

### Build image:
docker build -t dockermule -f DockerFile .

### Run docker:
docker run -p 8082:8091 -t -i dockermule

### Check & verify:
docker ps
docker exec tagName -it /bin/bash
ls -ltr
cd logs
