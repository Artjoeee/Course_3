namespace ASPA0011_1.Logging
{
    public class FileLogger : ILogger
    {
        private readonly string _categoryName;
        private readonly string _filePath;
        private static readonly object _lock = new object();

        public FileLogger(string categoryName, string filePath)
        {
            _categoryName = categoryName;
            _filePath = filePath;
        }

        public IDisposable? BeginScope<TState>(TState state) => null;

        public bool IsEnabled(LogLevel logLevel) => logLevel != LogLevel.None;

        public void Log<TState>(LogLevel logLevel, EventId eventId,
            TState state, Exception? exception, Func<TState, Exception?, string> formatter)
        {
            if (!IsEnabled(logLevel))
            { 
                return; 
            }

            string message = formatter(state, exception);

            string record = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} | {logLevel,-9} | {_categoryName,-30} | {message}";

            if (exception != null)
            { 
                record += Environment.NewLine + exception; 
            }

            lock (_lock)
            {
                Directory.CreateDirectory(Path.GetDirectoryName(_filePath)!);
                File.AppendAllText(_filePath, record + Environment.NewLine);
            }
        }
    }
}
