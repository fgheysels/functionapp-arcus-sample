using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace FunctionApp.Arcus
{
    public static class ArcusObservabilityFunction
    {
        [FunctionName(nameof(ArcusObservabilityFunction))]
        public static void Run([TimerTrigger("*/10 * * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"Arcus Observability function executed at: {DateTime.Now}");
        }
    }
}
