-- The base Localize class.
Localize = Object:extend()
function Localize:init(localizeName, lang)
  self.table = self:FileRead("assets/texts/" .. localizeName .. ".json", lang)
end


function Localize:FileRead(filePath, lang)
    local data = nil
    local handle = io.open(filePath, "r")

    if handle then
        data = json:decode(handle:read("*a"))
        io.close(handle)
    end

    return data[lang]
end
