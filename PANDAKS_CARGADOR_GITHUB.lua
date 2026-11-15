-- ESCANER PANDAKS V243 - CARGADOR GITHUB CONFIGURADO
-- Repositorio: https://github.com/PandaksYT/Es241231
-- Admite los 9 modulos protegidos en la raiz o dentro de V243/.
-- NO ofuscar hasta comprobar que funciona con Delta Android.

local REPOSITORIO = "https://raw.githubusercontent.com/PandaksYT/Es241231/main/"
local RUTAS = {REPOSITORIO, REPOSITORIO .. "V243/"}
local VERSION = "V243_MODULAR_FUNCIONAL_01"
local BASE = nil
local MAIN_COUNT, GHOST_COUNT = 5, 4
local MAX_REINTENTOS = 3
local BASE_ENV = (getfenv and getfenv(1)) or _G

if type(loadstring) ~= "function" or type(setfenv) ~= "function" then
    error("[PANDAKS V243] Delta necesita loadstring y setfenv para este cargador.")
end

local function pedir(url)
    local respuesta = game:HttpGet(url .. "?v=" .. VERSION)
    if type(respuesta) ~= "string" or #respuesta < 10
       or respuesta:find("<!DOCTYPE", 1, true)
       or respuesta:find("404: Not Found", 1, true) then
        error("Respuesta vacia o archivo inexistente: " .. url)
    end
    return respuesta
end

-- Seleccionar una sola carpeta para los nueve modulos, evitando mezclarlos.
local function elegirBase()
    local archivoPrueba = "PANDAKS_FANTASMA_01.lua"
    for _, ruta in ipairs(RUTAS) do
        local ok, contenido = pcall(pedir, ruta .. archivoPrueba)
        if ok then
            local fn, err = loadstring(contenido)
            if fn then return ruta, fn end
            warn("[PANDAKS V243] Archivo no compilable en " .. ruta .. ": " .. tostring(err))
        end
    end
    error("[PANDAKS V243] No encuentro PANDAKS_FANTASMA_01.lua en la raiz ni en V243/. Subi los nueve archivos protegidos y conserva sus nombres.")
end

local primerFantasma
BASE, primerFantasma = elegirBase()

local function descargar(archivo)
    local ultimoError = "sin respuesta"
    for intento = 1, MAX_REINTENTOS do
        local ok, res = pcall(pedir, BASE .. archivo)
        if ok then return res end
        ultimoError = tostring(res)
        if intento < MAX_REINTENTOS then task.wait(0.6) end
    end
    error("[PANDAKS V243] No se pudo descargar " .. archivo .. ": " .. ultimoError)
end

local function compilar(archivo)
    local fuente = descargar(archivo)
    local fn, err = loadstring(fuente)
    fuente = nil
    if not fn then
        error("[PANDAKS V243] Error compilando " .. archivo .. ": " .. tostring(err))
    end
    return fn
end

local entorno = setmetatable({}, {__index = BASE_ENV})
local fantasma = {}
for i = 1, GHOST_COUNT do
    local archivo = string.format("PANDAKS_FANTASMA_%02d.lua", i)
    fantasma[i] = {nombre = archivo, funcion = i == 1 and primerFantasma or compilar(archivo)}
end

entorno.__PANDAKS_EJECUTAR_FANTASMA = function()
    local contexto = setmetatable({}, {__index = entorno})
    for _, modulo in ipairs(fantasma) do
        setfenv(modulo.funcion, contexto)
        local ok, err = pcall(modulo.funcion)
        if not ok then
            error("[PANDAKS V243] Fallo en " .. modulo.nombre .. ": " .. tostring(err))
        end
    end
end

for i = 1, MAIN_COUNT do
    local archivo = string.format("PANDAKS_PRINCIPAL_%02d.lua", i)
    local funcion = compilar(archivo)
    setfenv(funcion, entorno)
    local ok, err = pcall(funcion)
    if not ok then
        error("[PANDAKS V243] Fallo en " .. archivo .. ": " .. tostring(err))
    end
end

return true
