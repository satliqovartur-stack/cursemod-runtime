FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY app/ ./
COPY payload/ ./payload/
ENV ASPNETCORE_ENVIRONMENT=Production
USER app
EXPOSE 10000
ENTRYPOINT ["sh", "-c", "exec dotnet Cursemod.UpdateServer.dll --urls http://0.0.0.0:${PORT:-10000}"]
