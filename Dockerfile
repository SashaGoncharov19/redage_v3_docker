FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-dotnet

WORKDIR /app

COPY ./dotnet ./dotnet

RUN cd dotnet/resources && dotnet restore NeptuneEvo.sln

RUN cd dotnet/resources && dotnet build NeptuneEvo.sln --configuration Debug --no-restore

FROM node:16.14.0-alpine AS build-js

WORKDIR /app

COPY ./src_cef ./src_cef
COPY ./src_client ./src_client

RUN cd ./src_cef && npm install --legacy-peer-deps && npm run build
RUN cd ./src_client && npm install && npm run build

FROM debian:10 AS runtime

WORKDIR /server

RUN apt update && apt install -y wget libatomic1 rsync libicu-dev && \
    apt clean autoclean && \
    apt autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN wget https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 5.0 --runtime aspnetcore --install-dir /usr/share/dotnet && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

COPY --from=build-js ./app/client_packages ./client_packages
COPY --from=build-dotnet ./app/dotnet ./dotnet

RUN wget https://cdn.rage.mp/updater/prerelease/server-files/linux_x64.tar.gz -O server-files.tar.gz && \
    tar -xzf server-files.tar.gz && \
    rsync -a ragemp-srv/ ./ && \
    rm -rf server-files.tar.gz ragemp-srv

COPY ./json ./json
COPY ./settings ./settings
COPY ./conf.json ./conf.json

COPY ./client_packages/index.js ./client_packages/index.js
COPY ./client_packages/rage-rpc.min.js ./client_packages/rage-rpc.min.js
COPY ./client_packages/game_resources ./client_packages/game_resources

COPY ./client_packages/interface/cloud.html ./client_packages/interface/cloud.html
COPY ./client_packages/interface/local.html ./client_packages/interface/local.html

RUN cp -r ./dotnet/resources/NeptuneEvo/Bootstrapper.dll ./dotnet/runtime/Bootstrapper.dll

RUN chmod +x ragemp-server

EXPOSE 22005/udp 22006

CMD ["./ragemp-server"]