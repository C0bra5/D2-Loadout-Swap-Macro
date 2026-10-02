#Requires AutoHotkey v2.0

class HighResTimer {
    static QPF := 0

    static Initialize() {
        DllCall("winmm\timeBeginPeriod", "UInt", 1)
        qpf := 0
        DllCall("QueryPerformanceFrequency", "Int64*", &qpf)
        this.QPF := qpf
    }

    static Cleanup() {
        DllCall("winmm\timeEndPeriod", "UInt", 1)
    }

    static Sleep(ms, onTick := "") {
        if ms <= 0
            return

        start := 0
        DllCall("QueryPerformanceCounter", "Int64*", &start)
        target := start + (ms / 1000.0) * this.QPF
        intervalTicks := (8 / 1000.0) * this.QPF ; 8ms tick interval (~125 Hz)
        nextTick := start + intervalTicks

        now := 0
        loop {
            DllCall("QueryPerformanceCounter", "Int64*", &now)
            if (now >= target)
                break

            ; Execute sub-interval tick callback if provided
            if (onTick != "" && now >= nextTick) {
                stopEarly := onTick()
                if (stopEarly)
                    break
                nextTick := now + intervalTicks
            }

            ; Yield coarse slice to OS scheduler if enough time remains
            remainingMs := (target - now) / this.QPF * 1000.0
            if (remainingMs > 12) {
                Sleep(4)
            }
        }
    }
}
