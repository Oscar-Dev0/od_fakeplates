function Translate(key)
    local locale = Locales[Config.Locale] or Locales.en
    return locale[key] or Locales.en[key] or key
end
