# Quickstart Backend with SQL Database Connection

This use case involves deploying an Azure App Service with an Azure SQL Database to provide a lightweight backend environment for testing new application features. It includes everything from hosting the app to managing data persistence and integrates CI/CD for easy testing and iteration.

## Objectives

- Deploy a scalable and secure web backend on Azure for testing new application features.
- Automate the infrastructure provisioning using Bicep.
- Integrate continuous deployment for the application for frequent testing and easy updates.

## Components Overview

- Azure App Service - Deploy a simple backend API.
- Azure SQL Database - Set up a SQL database for persistence.
- Azure Container Registry (Optional) - Store container images for versioning (if you're using a containerized version).
- Continuous Integration/Continuous Deployment (CI/CD) - Automate deployment using GitHub Actions.