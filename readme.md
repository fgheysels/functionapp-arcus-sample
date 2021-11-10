## Introduction

This is a sample repository which demonstrates how [Arcus.Observability](https://github.com/arcus-azure/arcus.observability) can be integrated inside Azure FunctionApps.

There are 2 FunctionApps defined in this repository:

- FunctionApp.Regular
  This Function does not use Arcus.Observability to log to App Insights

- FunctionApp.Arcus
  This Function is using Arcus.Observability to log to App Insights

## Deploying

### Azure Resources

Deploy the required Azure Resources that are described in the `resources.bicep` file via this command:

```
az deployment group create --subscription <subscription-id> --resource-group <resourcegroup-name> --template-file .\resources.bicep
```

You'll be asked to provide a value for certain parameters. Alternatively, you can also specify the parameters in the command itself:

```
az deployment group create --subscription <subscription-id> --resource-group <resourcegroup-name> `
    --template-file .\resources.bicep `
    --parameters loganalytics_name=<value> appinsights_name=<value> ...
```

### Function Apps

Once the resources are created in Azure, you can deploy the FunctionApps.  This can easily be done from within Visual Studio.