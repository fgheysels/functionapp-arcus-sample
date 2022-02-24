using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Serilog;
using Serilog.Configuration;

namespace FunctionApp.Arcus
{
    class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var configuration = builder.GetContext().Configuration;

            builder.Services.AddLogging(loggingBuilder => ConfigureLogging(loggingBuilder, configuration));
        }

        private static void ConfigureLogging(ILoggingBuilder builder, IConfiguration configuration)
        {
            var logConfiguration = new LoggerConfiguration()
                                   //.ReadFrom.Configuration(configuration)
                                   .MinimumLevel.Information()
                                   .Enrich.FromLogContext()
                                   .Enrich.WithComponentName("ArcusLoggingFunctionApp")
                                   .WriteTo.Console();

            var telemetryKey = configuration.GetValue<string>("APPINSIGHTS_INSTRUMENTATIONKEY");

            if (!String.IsNullOrWhiteSpace(telemetryKey))
            {
                logConfiguration.WriteTo.AzureApplicationInsights(telemetryKey);
            }

            
            builder.AddSerilog(logConfiguration.CreateLogger());
        }
    }
}
