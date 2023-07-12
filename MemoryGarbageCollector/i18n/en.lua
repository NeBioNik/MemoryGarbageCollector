local Strings = {
    ADDON_DESCRIPTION = "The enabled add-on will perform LUA garbage collection when the current memory consumption exceeds the specified level.",
    AUTO_CLEAR = "Enable cleanup",
    AUTO_CLEAR_TOOLTIP = "Enable automatic memory cleanup of unused variables.",
    REFRESH_RATE = "Time between attempts, min",
    REFRESH_RATE_TOOLTIP = "Once every N minutes, memory will be cleared if a violation of the specified limits is detected.",
    COMPARISON_METHOD = "Comparison of memory spent",
    COMPARISON_METHOD_TOOLTIP = "Memory consumption is exceeded, either relative (%%) or absolute (MB).",
    OVERFLOW_RELATIVE = "Relative (%%)",
    OVERFLOW_RELATIVE_TOOLTIP = "The percentage of memory exceeded at which it is necessary to cause a cleanup",
    OVERFLOW_ABSOLUTE = "Absolute (MB)",
    OVERFLOW_ABSOLUTE_TOOLTIP = "The value of memory exceeded at which it is necessary to cause a cleanup",
    SHOW_DEBUG_MESSAGES = "Show debug messages",
    MEMORY_INIT_MAX = "|ceeeeeeMemory limit set: |cAFD3FF%d MB.",
    MEMORY_OVERFLOW_DEBUG = "|ceeeeeeNow: |c77ff7a%d MB; |ceeeeeeLimit: |cAFD3FF%d MB.",
    MEMORY_OVERFLOW_REACHED = "|ceeeeeeBefore: |cff7d77%d MB; |ceeeeeeAfter: |c77ff7a%d MB; |ceeeeeeCleared: |cAFD3FF%d MB.",
}

for stringId, stringValue in pairs(Strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end