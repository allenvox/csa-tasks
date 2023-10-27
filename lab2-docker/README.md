# Executing C++ in Docker
❗ Make sure you have working Docker (check by running `docker -v` in terminal) ❗<br><br>
To build container: `docker build -t example .`<br>
To run: `docker run -it -e VAR1='Hi!' example`<br>
<br>
All at once: `sh docker-finalize.sh`