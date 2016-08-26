FROM dnxza/lamp:latest

MAINTAINER DNX DragoN "ratthee.jar@hotmail.com"

RUN apt-get update \
&& apt-get install -y libapache2-mod-perl2 \
&& rm -rf /var/lib/apt/lists/*



CMD [ "/bin/bash", "/start.sh", "start" ]