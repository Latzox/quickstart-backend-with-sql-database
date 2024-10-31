targetScope = 'subscription'

@description('The Azure region where the resources should be deployed')
param deploymentLocation string = 'switzerlandnorth'

@description('The name of the resource group for the web application')
param appRgName string = uniqueString('rg', subscription().subscriptionId)

@description('The name of the resource group for the SQL resources')
param sqlRgName string = uniqueString('rg2', subscription().subscriptionId)

@description('The subscription ID for the sample sql resources subscription')
param subIdSampleSql string = '00000000-0000-0000-0000-000000000000'

@description('The name of the SQL logical server.')
param serverName string = uniqueString('sql', subscription().subscriptionId)

@description('The name of the SQL Database.')
param sqlDBName string = 'SampleDB'

@description('The tenant id')
param tenantId string = subscription().tenantId

@description('The name of the sql server admin.')
param sqlAdminName string = 'latzox'

@description('The entra object id of the sql server admin.')
param sqlAdminObjectId string = 'c104f006-8937-4583-8efc-2eb71b8bceb6'

@description('The user type of the sql server admin.')
param principalType string = 'User'

@description('The azureADOnlyAuthentication of the sql server admin.')
param azureADOnlyAuthentication bool = true

@description('The sku name of the sql database.')
param sqlDBSkuName string = 'GP_S_Gen5'

@description('The sku tier of the sql database.')
param sqlDBSkuTier string = 'GeneralPurpose'

@description('The capacity of the sql database.')
param capacity int = 1

@description('The subscription ID for the Azure Container Registry')
param subIdAcr string = '00000000-0000-0000-0000-000000000000'

@description('The name of the resource group for the Azure Container Registry')
param acrRgName string = 'rg-acr-prod-001'

@description('The base name of the web application')
param applicationName string = 'samplesql-prod'

@description('The SKU for the App Service Plan.')
param aspSkuName string = 'B1'

@description('The Docker image to deploy to the api')
param dockerImage string = 'latzox.azurecr.io/sample-backend-with-sql-database:latest'

@description('Role definition ID for ACR pull role.')
param roleDefinitionId string = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

@description('The resource group for the web application')
resource appRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: appRgName
  location: deploymentLocation
  tags: {
    workload: 'Sample Backend with SQL Database'
    topic: 'Backend'
    environment: 'Production'
  }
}

@description('The resource group for the web application')
resource sqlRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: sqlRgName
  location: deploymentLocation
  tags: {
    workload: 'Sample Backend with SQL Database'
    topic: 'SQL'
    environment: 'Production'
  }
}

module sql 'sql/sql.bicep' = {
  name: 'sql-deployment'
  scope: resourceGroup(subIdSampleSql, sqlRgName)
  params: {
    serverName: serverName
    sqlDBName: sqlDBName
    location: deploymentLocation
    tenantId: tenantId
    sqlAdminName: sqlAdminName
    sqlAdminObjectId: sqlAdminObjectId
    principalType: principalType
    azureADOnlyAuthentication: azureADOnlyAuthentication
    sqlDBSkuName: sqlDBSkuName
    sqlDBSkuTier: sqlDBSkuTier
    capacity: capacity
  }
  dependsOn: [
    sqlRg
  ]
}

module app 'app/app.bicep' = {
  name: 'app-deployment'
  scope: resourceGroup(subIdSampleSql, appRgName)
  params: {
    applicationName: applicationName
    aspSkuName: aspSkuName
    dockerImage: dockerImage
    sqlServerName: serverName
    sqlDatabaseName: sqlDBName
  }
  dependsOn: [
    appRg
  ]
}

module roleAssignment 'roleassignment/roles.bicep' = {
  name: 'roleassignment-deployment'
  scope: resourceGroup(subIdAcr, acrRgName)
  params: {
    roleDefinitionId: roleDefinitionId
    managedIdentityPrincipalId: app.outputs.managedIdentityPrincipalId
  }
}
