#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM registry.access.redhat.com/ubi8/dotnet-50-runtime:5.0-17 AS base
WORKDIR /app
USER 1001
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src


RUN apt-get update \
 && apt-get install -y \
    gcc \
    fortunes \
    cowsay \
 && pip install apache-airflow[crypto,postgres]

COPY ["exploregithub.csproj", "."]
RUN dotnet restore "./exploregithub.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "exploregithub.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "exploregithub.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "exploregithub.dll"]