using ASPA0011_1.Logging;
using ASPA0011_1.Services;

var criticalLoggerFactory = LoggerFactory.Create(cfg =>
{
    cfg.ClearProviders();
    cfg.AddProvider(new FileLoggerProvider("Logs/aspa.log"));
    cfg.AddConsole();
});

var criticalLogger = criticalLoggerFactory.CreateLogger("Startup");

if (!File.Exists("appsettings.json"))
{
    criticalLogger.LogCritical("Config 'appsettings.json' not found");
    return;
}

var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();

builder.Logging.AddConfiguration(builder.Configuration.GetSection("Logging"));

builder.Logging.AddConsole();
builder.Logging.AddDebug();
builder.Logging.AddProvider(new FileLoggerProvider("Logs/aspa.log"));

builder.Services.AddSingleton<ChannelManager>();
builder.Services.AddControllers();

var app = builder.Build();

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseAuthorization();

app.MapControllers();

app.Run();
