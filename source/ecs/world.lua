class("World").extends()

function World:init()
    self.entities = {}
    self.systems = {}
    self.idCounter = 1
end

function World:addEntity(entity)
    local index = self.idCounter
    entity.id = index
    self.entities[index] = entity

    self.idCounter = self.idCounter + 1

    for i = 1, #self.systems do
        self._updateSystemFilters(self.systems[i], entity, index)
    end
end

function World:entityUpdated(entity)
    local index = entity.id
    self.entities[index] = entity

    for i = 1, #self.systems do
        self._updateSystemFilters(self.systems[i], entity, index)
    end
end

local systemTableKey = "SYSTEM_TABLE_KEY"

local function processingSystemUpdate(system, dt)
    local preProcess = system.preProcess
    local process = system.process
    local postProcess = system.postProcess

    if preProcess then
        preProcess(system, dt)
    end

    if process then
        local entities = system.entities
        for i = 1, #entities do
            process(system, entities[i], dt)
        end
    end

    if postProcess then
        postProcess(system, dt)
    end
end

function World.processingSystem(table)
    table = table or {}
    table[systemTableKey] = true
    table.update = processingSystemUpdate
    table.entities = {}
    return table;
end

function World:_updateSystemFilters(system, entity)
    local filter = system.filter
    local index = entity.id
    if filter and filter(system, entity) then
        system.entities[index] = entity
        local onAdd = system.onAdd
        if onAdd then
            onAdd(system, entity)
        end
    end
end

function World:addSystem(system)
    local index = #self.systems + 1
    self.systems[index] = system

    for i = 1, #self.entities do
        local entity = self.entities[i]
        self:_updateSystemFilters(system, entity)
    end
end

function World:update(dt)
    for i = 1, #self.systems do
        local system = self.systems[i]
        local update = system.update
        if update then
            update(system, dt)
        end
    end
end
