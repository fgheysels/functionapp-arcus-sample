targetScope = 'resourceGroup'

@description('The Azure region that we deploy to')
param deploy_location string = 'westeurope'

param loganalytics_name string 
param appinsights_name string

param functionapp_storageaccount_name string
param functionapp_hostingplan_name string
param functionapp_regular_name string
param functionapp_arcus_name string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: loganalytics_name
  location: deploy_location
  tags: {    
  }  
  properties: {    
    sku: {      
      name: 'PerGB2018'
    }  
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appinsights_name
  location: deploy_location
  tags: {
    // circular dependency means we can't reference functionApp directly  /subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Web/sites/<appName>"
    // 'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${functionAppName}': 'Resource'
  }
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    CustomMetricsOptedInType: 'WithDimensions'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  dependsOn: [
    logAnalytics
  ]
}

resource functionapp_storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: functionapp_storageaccount_name
  location: deploy_location
  tags: {    
  }
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'  
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true            
    isHnsEnabled: true    
    minimumTlsVersion: 'TLS1_2'
  }
}

resource functionapp_hostingplan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: functionapp_hostingplan_name
  location: deploy_location
  sku: {
    name: 'Y1' 
    tier: 'Dynamic'
  }
  properties:{
    reserved: true
  }
}

resource functionapp_regular 'Microsoft.Web/sites@2021-02-01' = {
  name: functionapp_regular_name
  location: deploy_location  
  kind: 'functionapp,linux'  
  properties: {      
    httpsOnly: true    
    serverFarmId: functionapp_hostingplan.id
    siteConfig: {      
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionapp_storageaccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionapp_storageaccount.id, functionapp_storageaccount.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }  
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        } 
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        } 
      ]
      autoHealEnabled: false     
      }    
  }
  dependsOn: [
    functionapp_storageaccount
    functionapp_hostingplan
    appInsights
  ]
}

resource functionapp_arcus 'Microsoft.Web/sites@2021-02-01' = {
  name: functionapp_arcus_name
  location: deploy_location  
  kind: 'functionapp,linux'  
  properties: {      
    httpsOnly: true    
    serverFarmId: functionapp_hostingplan.id
    siteConfig: {      
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionapp_storageaccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionapp_storageaccount.id, functionapp_storageaccount.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }   
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        } 
      ]
      autoHealEnabled: false     
      }    
  }
  dependsOn: [
    functionapp_storageaccount
    functionapp_hostingplan
    appInsights
  ]
}
