local strings = {
    ADDON_DESCRIPTION = "Включённый аддон будет выполнять сбор мусора LUA (garbage collect) при превышения текущего потребления памяти выше заданной планки.",
    AUTO_CLEAR = "Включить очистку",
    AUTO_CLEAR_TOOLTIP = "Включить автоматическую очистку памяти от неиспользуемыых переменных.",
    REFRESH_RATE = "Время между попытками, мин",
    REFRESH_RATE_TOOLTIP = "Раз в N минут, будет проводиться очистка памяти, если обнаружено нарушение заданных пределов.",
    COMPARISON_METHOD = "Сравнение затраченной памяти",
    COMPARISON_METHOD_TOOLTIP = "Превышение потребления памяти, в относительном значении (%%) или в абсолютном (Мб).",
    OVERFLOW_RELATIVE = "Относительное значение (%%)",
    OVERFLOW_RELATIVE_TOOLTIP = "При превышении потребления памяти на N %%, относительно стартового значения, будет произведена очистка.",
    OVERFLOW_ABSOLUTE = "Абсолютное значение (Мб)",
    OVERFLOW_ABSOLUTE_TOOLTIP = "При превышении потребления памяти на N Мб, относительно стартового значения, будет произведена очистка.",
    SHOW_DEBUG_MESSAGES = "Показывать отладочные сообщения",
    MEMORY_INIT_MAX = "|ceeeeeeУстановлен лимит потребления памяти: |cAFD3FF%d Мб.",
    MEMORY_OVERFLOW_DEBUG = "|ceeeeeeСейчас: |c77ff7a%d Мб; |ceeeeeeЛимит: |cAFD3FF%d Мб.",
    MEMORY_OVERFLOW_REACHED = "|ceeeeeeДо: |cff7d77%d Мб; |ceeeeeeПосле: |c77ff7a%d Мб; |ceeeeeeОсвобождено: |cAFD3FF%d Мб.",
}

for id, val in pairs(strings) do
    SafeAddString(_G[id], val, 1)
end
