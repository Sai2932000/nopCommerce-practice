# ==========================================
# Stage 1 - Build
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build

WORKDIR /src

# Copy entire repository
COPY . .

# Move to Nop.Web project
WORKDIR /src/src/Presentation/Nop.Web

# Restore NuGet packages
RUN dotnet restore Nop.Web.csproj

# Publish application
RUN dotnet publish \
    Nop.Web.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ==========================================
# Stage 2 - Runtime
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine

LABEL author="saikumarthumma"
LABEL project="nopCommerce"
LABEL version="5.0"
LABEL description="nopCommerce ASP.NET Core application using Docker multi-stage build"
LABEL maintainer="saikumarthumma"

# Create non-root user
RUN addgroup -S nop && \
    adduser -S nop-user -G nop -h /app

WORKDIR /app

# Copy published application
COPY --from=build --chown=nop-user:nop /app/publish .

# Run as non-root
USER nop-user

# Expose application port
EXPOSE 8080

ENTRYPOINT ["dotnet", "Nop.Web.dll"]