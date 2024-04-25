---@alias TextComponentHoverEventAction ('show_text'|'show_item'|'show_entity')
---@alias TextComponentHoverEvent { action: TextComponentHoverEventAction, contents: string|TextJsonComponent }
---@alias TextComponentClickEventAction ('open_url'|'open_file'|'run_command'|'suggest_command')
---@alias TextComponentClickEvent { action_wheel: TextComponentClickEventAction, value: string }
---@alias color ('#<HEX>'|'black'|'dark_blue'|'dark_green'|'dark_aqua'|'dark_red'|'dark_purple'|'gold'|'gray'|'dark_gray'|'blue'|'green'|'aqua'|'red'|'light_purple'|'yellow'|'white')
---@alias TextJsonComponent { text?: string, translate?: string, extra?: TextJsonComponent[], color?: color, font?: string, bold?: boolean, italic?: boolean, underlined?: boolean, strikethrough?: boolean, obfuscated?: boolean, insertion?: string, clickEvent?: TextComponentClickEvent, hoverEvent?: TextComponentHoverEvent }
---@alias BunnyChatUtils.RegistryFunction fun(self: BunnyChatUtils, chatJson: TextJsonComponent, rawText: string): TextJsonComponent, string

---@class BunnyChatUtils
local BunnyChatUtils = {
    ---@type BunnyChatUtils.RegistryFunction[]
    __REGISTRY = {},
    __VARS = {}
}

---@param self BunnyChatUtils
---@param func BunnyChatUtils.RegistryFunction
---@param name string
function BunnyChatUtils.register(self, func, name)
    self.__REGISTRY[name] = func
end

---@param self BunnyChatUtils
---@param rawText string
---@param jsonText TextJsonComponent
function BunnyChatUtils.process(self, rawText, jsonText)
    local newJsonText
    local newRawText
    for _, v in pairs(self.__REGISTRY) do
        if not newJsonText then
            newJsonText, newRawText = v(self, jsonText, rawText)
        else
            newJsonText, newRawText = v(self, newJsonText, newRawText)
        end
    end
    return newJsonText
end

---@param self BunnyChatUtils
---@param var string
function BunnyChatUtils.getCustomVar(self, var)
    return self.__VARS[var]
end

---@param self BunnyChatUtils
---@param var string
---@param val any
function BunnyChatUtils.setCustomVar(self, var, val)
    self.__VARS[var] = val
end

BunnyChatUtils:register(function(self, jsonText, rawText)
    if self:getCustomVar("prevText") == nil then
        self.__VARS["prevText"] = rawText
        self.__VARS["messageCount"] = 1
        return jsonText, rawText
    end

    if rawText:gsub('%s*$', '') == self.__VARS["prevText"]:gsub('%s*$', '') then
        self.__VARS["messageCount"] = self.__VARS["messageCount"] + 1
        host:setChatMessage(1, nil)
        if jsonText.extra then
            table.insert(jsonText.extra, {text = " (", color = "dark_gray"})
            table.insert(jsonText.extra, {text = "x", color = "gray"})
            table.insert(jsonText.extra, {text = tostring(self.__VARS["messageCount"]), color = "#A0FFA0"})
            table.insert(jsonText.extra, {text = ")", color = "dark_gray"})

            return jsonText, rawText
        else
            table.insert(jsonText, {text = " (", color = "dark_gray"})
            table.insert(jsonText.extra, {text = "x", color = "gray"})
            table.insert(jsonText, {text = tostring(self.__VARS["messageCount"]), color = "#A0FFA0"})
            table.insert(jsonText, {text = ")", color = "dark_gray"})

            return jsonText, rawText
        end
    end

    self.__VARS["prevText"] = rawText
    self.__VARS["messageCount"] = 1
    return jsonText, rawText
end, 'BUILTIN.FILTER_SPAM')

BunnyChatUtils:register(function(self, jsonText, rawText)
    jsonText = parseJson(toJson(jsonText):gsub('"<"', '""'):gsub('"> "', '": "')) --[[@as TextJsonComponent]]
    jsonText = parseJson(toJson(jsonText):gsub("\"<(.-)>", "\"%1:")) --[[@as TextJsonComponent]]

    return jsonText, rawText
end, 'BUILTIN.PLAYERNAME_FORMAT')

events.CHAT_RECEIVE_MESSAGE:register(function (rawText, jsonText)
    return toJson(BunnyChatUtils:process(rawText, parseJson(jsonText) --[[@as TextJsonComponent]]))
end)

return BunnyChatUtils