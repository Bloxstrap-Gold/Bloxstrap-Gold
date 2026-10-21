using System.Diagnostics;

namespace Bloxstrap
{
    public static class MultiInstanceWatcher
    {
        private static Mutex? _heldMutex = null;
        private static EventWaitHandle? _heldEvent = null;

        public static bool IsMutexHeld => _heldMutex != null;

        public static int GetOpenProcessesCount()
        {
            const string LOG_IDENT = "MultiInstanceWatcher::GetOpenProcessesCount";

            try
            {
                int count = Process.GetProcesses().Count(x =>
                    x.ProcessName.Equals(App.RobloxPlayerAppName, StringComparison.OrdinalIgnoreCase) ||
                    x.ProcessName.Equals("RobloxPlayerBeta", StringComparison.OrdinalIgnoreCase) ||
                    x.ProcessName.Equals(App.ProjectName, StringComparison.OrdinalIgnoreCase) ||
                    x.ProcessName.Equals("Bloxstrap", StringComparison.OrdinalIgnoreCase) ||
                    x.ProcessName.Equals("Bloxstrap Gold", StringComparison.OrdinalIgnoreCase));

                count -= 1; // ignore current process
                return Math.Max(0, count);
            }
            catch (Exception ex)
            {
                App.Logger.WriteException(LOG_IDENT, ex);
                return -1;
            }
        }

        public static void FireInitialisedEvent()
        {
            try
            {
                using EventWaitHandle initEventHandle = new EventWaitHandle(false, EventResetMode.AutoReset, "Bloxstrap-MultiInstanceWatcherInitialisationFinished");
                initEventHandle.Set();
            }
            catch { }
        }

        public static bool AcquireSingletonPrimitives()
        {
            const string LOG_IDENT = "MultiInstanceWatcher::AcquireSingletonPrimitives";

            try
            {
                if (_heldMutex == null)
                {
                    _heldMutex = new Mutex(false, "ROBLOX_singletonMutex");
                    bool acquired;
                    try
                    {
                        acquired = _heldMutex.WaitOne(0);
                    }
                    catch (AbandonedMutexException)
                    {
                        acquired = true;
                    }

                    if (!acquired)
                        App.Logger.WriteLine(LOG_IDENT, "Roblox singleton mutex already exists or is held by another process.");
                    else
                        App.Logger.WriteLine(LOG_IDENT, "Acquired ROBLOX_singletonMutex successfully!");
                }

                if (_heldEvent == null)
                {
                    try
                    {
                        _heldEvent = new EventWaitHandle(false, EventResetMode.ManualReset, "ROBLOX_singletonEvent");
                        App.Logger.WriteLine(LOG_IDENT, "Initialized ROBLOX_singletonEvent handle.");
                    }
                    catch { }
                }

                return true;
            }
            catch (Exception ex)
            {
                App.Logger.WriteException(LOG_IDENT, ex);
                return false;
            }
        }

        public static void ReleaseSingletonPrimitives()
        {
            const string LOG_IDENT = "MultiInstanceWatcher::ReleaseSingletonPrimitives";

            try
            {
                if (_heldMutex != null)
                {
                    _heldMutex.Dispose();
                    _heldMutex = null;
                    App.Logger.WriteLine(LOG_IDENT, "Released ROBLOX_singletonMutex.");
                }

                if (_heldEvent != null)
                {
                    _heldEvent.Dispose();
                    _heldEvent = null;
                    App.Logger.WriteLine(LOG_IDENT, "Released ROBLOX_singletonEvent.");
                }
            }
            catch (Exception ex)
            {
                App.Logger.WriteException(LOG_IDENT, ex);
            }
        }

        public static void Run()
        {
            const string LOG_IDENT = "MultiInstanceWatcher::Run";

            App.Logger.WriteLine(LOG_IDENT, "Multi-instance watcher started.");

            AcquireSingletonPrimitives();
            FireInitialisedEvent();

            // watch for alive processes
            int count;
            do
            {
                Thread.Sleep(3000);
                count = GetOpenProcessesCount();
            }
            while (count == -1 || count > 0);

            App.Logger.WriteLine(LOG_IDENT, "All Roblox-related processes closed, exiting multi-instance watcher.");
            ReleaseSingletonPrimitives();
        }
    }
}
