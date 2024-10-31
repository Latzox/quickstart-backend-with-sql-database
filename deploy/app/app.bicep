@description('The region in which to deploy the resources')
param location string = resourceGroup().location

@description('The base name of the web application')
param applicationName string

@description('The SKU for the App Service Plan.')
param aspSkuName string

@description('The Docker image to deploy to the api')
param dockerImage string

@description('The name of the SQL Server to use')
param sqlServerName string

@description('The name of the SQL Database to connect to')
param sqlDatabaseName string

@description('The tags to apply to the resources')
param tags object = {
  workload: 'Sample Backend with SQL Database'
  topic: 'Backend'
  environment: 'Production'
}

@description('User-assigned managed identity for the azure app service.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: '${applicationName}-identity'
  location: resourceGroup().location
  tags: tags
}


@description('Deploy an app service plan for each region specified')
resource appServicePlans 'Microsoft.Web/serverfarms@2023-12-01' =  {
  name: 'asp-${applicationName}'
  location: location
  tags: tags
  kind: 'linux'
  properties: {
    reserved: true
  }	
  sku: {
    name: aspSkuName
  }
}

@description('Deploy a web application for each region specified')
resource webApp 'Microsoft.Web/sites@2023-12-01' =  {
  name: 'app-${applicationName}'
  location: location
  kind: 'app,linux,container'
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    siteConfig: {
      minTlsVersion: '1.2'
      http20Enabled: true
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentity.properties.clientId
      linuxFxVersion: 'DOCKER|${dockerImage}'
      appSettings: [
        {
          name: 'SQL_SERVER'
          value: sqlServerName
        }
        {
          name: 'SQL_DATABASE'
          value: sqlDatabaseName
        }
      ]
    }
    httpsOnly: true
    clientAffinityEnabled: false
    serverFarmId: appServicePlans.id
  }
}

output managedIdentityPrincipalId string = managedIdentity.properties.principalId
