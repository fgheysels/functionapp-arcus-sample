using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System;

namespace FunctionApp.Regular
{
    public class RegularFunction
    {
        [FunctionName(nameof(RegularFunction))]
        public void Run([TimerTrigger("*/10 * * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"Regular Function executed at: {DateTime.Now}");
        }
    }
}
