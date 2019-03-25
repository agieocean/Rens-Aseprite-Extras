-- Copyright (C) 2019 Ren Finkle
--
-- This file is released under the terms of the CC BY 4.0 license.
-- See https://creativecommons.org/licenses/by/4.0/ for more information.
--
-- TODO: Palette loading
-- Version: Beta 1, March 24, 2019

-- Check is UI available
if not app.isUIAvailable then
    return
end

----------------------------------------------------------------------------------------------------
-- External functions ------------------------------------------------------------------------------
    -- http://lua-users.org/wiki/SaveTableToFile
    -- http://lua-users.org/wiki/SplitJoin
----------------------------------------------------------------------------------------------------

--// exportstring( string )
--// returns a "Lua" portable version of the string
function exportstring( s )
    return string.format("%q", s)
end

--// The Save Function
function table.save(  tbl,filename )
    local charS,charE = "   ","\n"
    local file,err = io.open( filename, "wb" )
    if err then return err end

    -- initiate variables for save procedure
    local tables,lookup = { tbl },{ [tbl] = 1 }
    file:write( "return {"..charE )

    for idx,t in ipairs( tables ) do
        file:write( "-- Table: {"..idx.."}"..charE )
        file:write( "{"..charE )
        local thandled = {}

        for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
                if not lookup[v] then
                table.insert( tables, v )
                lookup[v] = #tables
                end
                file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
                file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
                file:write(  charS..tostring( v )..","..charE )
            end
        end

        for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then
            
                local str = ""
                local stype = type( i )
                -- handle index
                if stype == "table" then
                if not lookup[i] then
                    table.insert( tables,i )
                    lookup[i] = #tables
                end
                str = charS.."[{"..lookup[i].."}]="
                elseif stype == "string" then
                str = charS.."["..exportstring( i ).."]="
                elseif stype == "number" then
                str = charS.."["..tostring( i ).."]="
                end
            
                if str ~= "" then
                stype = type( v )
                -- handle value
                if stype == "table" then
                    if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                    end
                    file:write( str.."{"..lookup[v].."},"..charE )
                elseif stype == "string" then
                    file:write( str..exportstring( v )..","..charE )
                elseif stype == "number" then
                    file:write( str..tostring( v )..","..charE )
                end
                end
            end
        end
        file:write( "},"..charE )
    end
    file:write( "}" )
    file:close()
end

--// The Load Function
function table.load( sfile )
    local ftables,err = loadfile( sfile )
    if err then return _,err end
    local tables = ftables()
    for idx = 1,#tables do
        local tolinki = {}
        for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
                tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
                table.insert( tolinki,{ i,tables[i[1]] } )
            end
        end
        -- link indices
        for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
    end
    return tables[1]
end

-- Compatibility: Lua-5.1
-- // Split String Function
function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

-- // Split Path Function
function split_path(str)
    return split(str,'[\\/]+')
end

function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

presetsDict = {{width=100, height=100}}
--table.save(presetsDict, "presets")
-- // Initialization
if file_exists("presets") then
    presetsDict = table.load("presets")
else
    table.save(presetsDict, "presets")
end

function addPreset(width, height, dlg)
    fentry = {width=width, height=height}
    exists = false
    for it, entry in ipairs(presetsDict) do
        if entry.width == fentry.width then
            if entry.height == fentry.height then
                exists = true
                break
            end
        end
    end
    if exists == false then
        table.insert(presetsDict, fentry)
        table.save(presetsDict, "presets")
    end
end

function deletePreset(width, height)
    fentry = {width=width, height=height}
    exists = false
    for it, entry in ipairs(presetsDict) do
        if entry.width == fentry.width then
            if entry.height == fentry.height then
                table.remove(presetsDict, it)
                table.save(presetsDict, "presets")
                break
            end
        end
    end
end

-- // Dialog
local dlg = Dialog()
dlg:entry{ id="width", label="Width:", text="100", decimals=false }
dlg:entry{ id="height", label="Height:", text="100", decimals=false }
poptions = {"Choose"}
for it, entry in ipairs(presetsDict) do
    table.insert(poptions, ""..entry.width.."X"..entry.height)
end
dlg:combobox{ id="presetl",
              label="Presets:",
              options=poptions
}
dlg:button{
    id="ok",
    text="OK",
    onclick=function()
        width = 1
        height = 1
        dlg:close()
        if dlg.data.presetl == "Choose" then
            width = tonumber(dlg.data.width)
            height = tonumber(dlg.data.height)
            addPreset(width, height, dlg)
        else
            wh = split(dlg.data.presetl, "X")
            width = tonumber(wh[1])
            height = tonumber(wh[2])
        end
        s = Sprite(width, height)
        dlg:close()
    end
}
dlg:button{
    id="delete",
    text="Delete",
    onclick=function()
        if dlg.data.presetl ~= "Choose" then
            wh = split(dlg.data.presetl, "X")
            width = tonumber(wh[1])
            height = tonumber(wh[2])
            deletePreset(width, height)
            dlg:close()
        end
    end
}
dlg:show()