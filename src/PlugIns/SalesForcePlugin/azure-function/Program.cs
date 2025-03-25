using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.Hosting;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication().ConfigureServices(ConfigureServices);

// Application Insights isn't enabled by default. See https://aka.ms/AAt8mw4.
builder.Services
    .AddApplicationInsightsTelemetryWorkerService()
    .ConfigureFunctionsApplicationInsights();
    .AddDebug()
    .AddConsole()
    .AddSingleton<IInventoryManagementService, InventoryManagementService>()
    .AddSingleton<ICusomerLeadService, CusomerLeadService>()
    ;

builder.Build().Run();


// void ConfigureServices(IServiceCollection services, IConfiguration config)
// {
//     services.AddSingleton(config);
//     // services.AddSingleton<ISrpIntervalDownloaderService, SrpIntervalDownloaderService>();
//     // services.AddSingleton<ILoginRepository, LoginRepository>();
//     // services.AddSingleton<IDatabaseService, DatabaseService>();
//     services.AddApplicationInsightsTelemetryWorkerService();
//     // services.ConfigureFunctionsApplicationInsights();
//     services.AddLogging(logging => {
//         logging.AddDebug();
//         logging.AddConsole();
//     });
// }
