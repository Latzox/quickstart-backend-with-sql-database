# Use a base image with PowerShell
FROM mcr.microsoft.com/azure-powershell:ubuntu-22.04   

# Update
RUN apt-get update && apt-get -y upgrade

# Install curl
RUN apt-get install curl -y

# Install coretools package for Ubuntu 22.04 from linux software repository
RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update && apt-get install azure-functions-core-tools-4

# Install Python
RUN apt-get install -y python3
