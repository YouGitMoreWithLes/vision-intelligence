using System;
using Azure.Storage.Queues.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace azure_function
{
    public class SalesforceAzureFunction
    {
        private readonly ILogger<SalesforceAzureFunction> _logger;

        public SalesforceAzureFunction(ILogger<SalesforceAzureFunction> logger)
        {
            _logger = logger;
        }

        [Function(nameof(SalesforceAzureFunction))]
        public void Run([QueueTrigger("myqueue-items", Connection = "")] QueueMessage message)
        {
            _logger.LogInformation($"C# Queue trigger function processed: {message.MessageText}");
        }
    }
}
