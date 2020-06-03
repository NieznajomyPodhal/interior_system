intTable = {}

function getOrganizationName()
	print("chuj")
end

intTable = {}

function loadInteriors()
	local query = exports.sy_db:getDB("SELECT * FROM mm_interiors")
	if not query or not query[1] then return print("#mm_houses/main.lua - 19#:nie można wczytać interiorów / 1 - brak / 2 - łącznie z bazą danych / 3 - błędne rekordy w kolumnie") end
	
	for k,v in pairs(query) do
		v.upgrades = v.upgrades and fromJSON(v.upgrades) or {}
		v.pickup = createPickup(v.ex, v.ey, v.ez, 3, v.type == 0 and 1273 or v.type == 3 and 1272 or v.type == 4 and 1275 or 1239, 0)
		setElementData(v.pickup, "intPickup", true)
		setElementData(v.pickup, "intInfo", v)
		intTable[v.uid] = v
		if v.upgrades.audio and v.audioLink then
			setTimer(triggerClientEvent, 50, 1, "createInteriorEntrySound", root, v.audioLink, {v.ex, v.ey, v.ez, v.edim, v.einterior}, v.uid)
		end
	end
end

function unloadInteriors()
	for k,v in pairs(intTable) do
		destroyElement(v.pickup)
		exports.sy_db:getDB("UPDATE mm_interiors SET name = ?, description = ?, vehEnter = ?, map = ?, locked = ?, residents = ?, upgrades = ?, ex = ?, ey = ?, ez = ?, erot = ?, edim = ?, einterior = ?, intx = ?, inty = ?, intz = ?, items = ?, audioLink = ?, interior = ?, objects = ?, moreObjects = ? WHERE uid = ?", v.name, v.description, v.vehEnter, v.map, v.locked, v.residents, toJSON(v.upgrades), v.ex, v.ey, v.ez, v.erot, v.edim, v.einterior, v.intx, v.inty, v.intz, v.items, v.audioLink, v.interior, v.objects, v.moreObjects, v.uid)
	end
	intTable = {}
end

function enterInterior(uid, plr)
	assert(type(uid) == "number", string.format("number expected at argument 1, got %s", type(uid)))
	assert(getElementType(plr) == "player", string.format("player expected at argument 2, got %s", getElementType(plr)))
	setElementInterior(isElement(client) and client or plr, intTable[uid].interior)
	setElementDimension(isElement(client) and client or plr, intTable[uid].dimension)
	setElementPosition(isElement(client) and client or plr, intTable[uid].intx, intTable[uid].inty, intTable[uid].intz)
	setElementRotation(isElement(client) and client or plr, 0, 0, intTable[uid].introt)
	setElementFrozen(isElement(client) and client or plr, true)
	triggerClientEvent(isElement(client) and client or plr, "createInteriorMap", isElement(client) and client or plr, intTable[uid].map, intTable[uid].intx, intTable[uid].inty, intTable[uid].intz, intTable[uid].audioLink, uid)
	if getElementData(isElement(client) and client or plr, "enteringPickup") then
		removeElementData(isElement(client) and client or plr, "enteringPickup")
	end
	setElementData(isElement(client) and client or plr, "actualInterior", uid)
	setTimer(fadeCamera, 1000, 1, isElement(plr) and plr or client, true, 2)
end

function exitInterior(uid, plr)
	assert(type(uid) == "number", string.format("number expected at argument 1, got %s", type(uid)))
	setElementInterior(isElement(plr) and plr or client, intTable[uid].einterior)
	setElementDimension(isElement(plr) and plr or client, intTable[uid].edim)
	setElementPosition(isElement(plr) and plr or client, intTable[uid].ex, intTable[uid].ey, intTable[uid].ez)
	setElementRotation(isElement(plr) and plr or client, 0, 0, intTable[uid].erot)
	setElementFrozen(isElement(plr) and plr or client, false)
	setTimer(fadeCamera, 1000, 1, isElement(plr) and plr or client, true, 2)
	removeElementData(isElement(plr) and plr or client, "actualInterior")
	removeElementData(isElement(plr) and plr or client, "exitingPickup")
end

function getInteriorOwner(uid)
	assert(type(uid) == "number", string.format("number expected at argument 1, got %s", type(uid)))
	if intTable[uid].ownerType == 2 then
		local name = getOrganizationName(intTable[uid].owner)
		if not name then return false end
		return string.format("%s (organizacja)", name)
	elseif intTable[uid].ownerType == 1 then
		local query = exports["sy_db"]:getDB("SELECT name FROM mm_users WHERE uid = ?", intTable[uid].owner)
		return string.format("%s (gracz)", query[1].name)
	else
		return "Nieznany"
	end
	return false
end

function updateDoorInfo(typ, uid, varTable)
	assert(type(typ) == "number", string.format("number expected at argument 1, got %s", type(typ)))
	assert(type(uid) == "number", string.format("number expected at argument 2, got %s", type(uid)))
	assert(type(varTable) == "table", string.format("table expected at argument 3, got %s", type(varTable)))
	if typ == 1 then
		intTable[uid].name, intTable[uid].description, intTable[uid].vehEnter = varTable[1], varTable[2], varTable[3]
		if getElementData(client, "enteringPickup") then
			triggerClientEvent(client, "refreshIntPickupGUI", client, intTable[uid])
		end
	elseif typ == 2 then
		intTable[uid].audioLink = varTable[1]
		for k,v in pairs(getElementsByType("player")) do
			if string.len(varTable[1]) ~= 0 then
				triggerClientEvent(v, "createInteriorEntrySound", v, intTable[uid].audioLink, {intTable[uid].ex, intTable[uid].ey, intTable[uid].ez, intTable[uid].edim, intTable[uid].einterior}, uid)
			else
				triggerClientEvent(v, "destroyInteriorSound", v, uid)
			end
		end
	elseif typ == 3 then
		intTable[uid].safeCode = varTable[1]
	elseif typ == 4 then
		intTable[uid].map, intTable[uid].intx, intTable[uid].inty, intTable[uid].intz = varTable[1], varTable[2].x, varTable[2].y, varTable[2].z
	elseif typ == 5 then
		intTable[uid].moreObjects, intTable[uid].objects = varTable[1], varTable[2]
		takePlayerMoney(client, varTable[3])
	end
	setElementData(intTable[uid].pickup, "intInfo", intTable[uid])
	exports['mm_notifications']:alert(client, "info", "Pomyślnie wczytano nowe ustawienia")
end

function getIntUIDFromDimAndInt(dim, int)
	assert(type(dim) == "number", string.format("number expected at argument 1, got %s", type(dim)))
	assert(type(int) == "number", string.format("number expected at argument 2, got %s", type(int)))
	for k,v in pairs(intTable) do
		if v.dimension == dim and v.interior == int then
			outputChatBox(dim)
			outputChatBox(int)
			return k
		end
	end
	return false
end

function loadInteriorSounds()
	for k,v in pairs(intTable) do
		if v.upgrades.audio and v.audioLink then
			triggerClientEvent(source, "createInteriorEntrySound", source, v.audioLink, {v.ex, v.ey, v.ez, v.edim, v.einterior}, v.uid)
		end
	end
end

function hasPlayerPermToDoors(plr, uid)
	assert(getElementType(plr) == "player", string.format("player expected at argument 1, got %s", getElementType(plr)))
	assert(type(uid) == "number", string.format("number expected at argument 2, got %s", type(uid)))
	if intTable[uid].owner == getElementData(plr, "UID") and intTable[uid].ownerType == 1 then return true end
	if intTable[uid].ownerType == 2 then return true end
	return false
end

function getInteriorInfo(uid)
	assert(type(uid) == "number", string.format("number expected at argument 1, got %s", type(uid)))
	if not intTable[uid] or type(intTable[uid]) ~= "table" then return false end
	return intTable[uid]
end

function getOrganizationInteriors(uid)
	assert(type(uid) == "number", string.format("number expected at argument 1, got %s", type(uid)))
	local tmpTable = {}
	for k,v in pairs(intTable) do
		if v.ownerType == 2 and v.owner == uid then
			table.insert(tmpTable, v)
		end
	end
	return tmpTable
end

function getPlayerInteriors(plr)
	assert(getElementType(plr) == "player", string.format("player expected at argument 1, got %s", getElementType(plr)))
	local tmpTable = {}
	for k,v in pairs(intTable) do
		if v.ownerType == 1 and v.owner == getElementData(plr, "uid") then
			table.insert(tmpTable, v)
		end
	end
	return tmpTable
end

function locateInterior(uid, plr)
	assert(type(uid) == "number", string.format("number expected at argument 1, got %s", type(uid)))
	if getElementData(isElement(plr) and plr or client, "locateInterior") then
		destroyElement(getElementData(isElement(plr) and plr or client, "locateInterior")[2])
		removeElementData(isElement(plr) and plr or client, "locateInterior")
	else
		local blip = createBlip(intTable[uid].ex, intTable[uid].ey, intTable[uid].ez,  0, 2, 0, 0, 255, 255, 0, 65535, isElement(plr) and plr or client)
		setElementData(isElement(plr) and plr or client, "locateInterior", {uid, blip})
	end
end

addCommandHandler("drzwi", function(plr, com, ...)
	if not getElementData(plr, "enteringPickup") and not getElementData(plr, "exitingPickup") and not getElementData(plr, "actualInterior") then return end
	
	local arg = {...}
	if arg[1] == "z" or arg[1] == "zamknij" then
		local uid
		local x, y = getElementPosition(plr)
		
		if getElementData(plr, "enteringPickup") then
			uid = getElementData(getElementData(plr, "enteringPickup"), "intInfo").uid
		elseif getDistanceBetweenPoints2D(x, y, getElementData(plr, "exitingPickup")[1], getElementData(plr, "exitingPickup")[2]) < 1 then
			uid = getElementData(plr, "actualInterior")
		else return end
		
	---	if not hasPlayerPermToDoors(plr, uid) then return end
		
		intTable[uid].locked = intTable[uid].locked == 1 and 0 or 1
		setElementData(intTable[uid].pickup, "intInfo", intTable[uid])
	triggerClientEvent("refreshIntPickupGUI", plr, intTable[uid])
		setPedAnimation(plr, "BD_Fire", "wash_up", -1, false, true, false, false)
		exports['mm_notifications']:alert(client, "info", string.format("%s budynek o nazwie %s", intTable[uid].locked == 1 and "Zamknięto" or "Otwarto", intTable[uid].name))
	else
		if getElementData(plr, "enteringPickup") then
			uid = getElementData(getElementData(plr, "enteringPickup"), "intInfo").uid
		else
			uid = getElementData(plr, "actualInterior")
		end
		if not uid then return end
		triggerClientEvent(plr, "createDoorInfoUI", plr, intTable[uid])
		return
	end
end)

addCommandHandler("z", function(plr, com)
	if not getElementData(plr, "enteringPickup") and not getElementData(plr, "exitingPickup") and not getElementData(plr, "actualInterior") then return end
	local uid
	local x, y = getElementPosition(plr)
	
	if getElementData(plr, "enteringPickup") then
		uid = getElementData(getElementData(plr, "enteringPickup"), "intInfo").uid
	elseif getDistanceBetweenPoints2D(x, y, getElementData(plr, "exitingPickup")[1], getElementData(plr, "exitingPickup")[2]) < 1 then
		uid = getElementData(plr, "actualInterior")
	else return end
	---if not hasPlayerPermToDoors(plr, uid) then return end
	
	intTable[uid].locked = intTable[uid].locked == 1 and 0 or 1
	setElementData(intTable[uid].pickup, "intInfo", intTable[uid])
	triggerClientEvent("refreshIntPickupGUI", plr, intTable[uid])
	setPedAnimation(plr, "BD_Fire", "wash_up", -1, false, true, false, false)
	exports['mm_notifications']:alert(client, "info", string.format("%s lokal", intTable[uid].locked == 1 and "Zamknięto" or "Otwarto"))
end)

addCommandHandler("zamknij", function(plr, com)
	if not getElementData(plr, "enteringPickup") and not getElementData(plr, "exitingPickup") and not getElementData(plr, "actualInterior") then return end
	local uid
	local x, y = getElementPosition(plr)
	
	if getElementData(plr, "enteringPickup") then
		uid = getElementData(getElementData(plr, "enteringPickup"), "intInfo").uid
	elseif getDistanceBetweenPoints2D(x, y, getElementData(plr, "exitingPickup")[1], getElementData(plr, "exitingPickup")[2]) < 1 then
		uid = getElementData(plr, "actualInterior")
	else return end
---	if not hasPlayerPermToDoors(plr, uid) then return end
	
	intTable[uid].locked = intTable[uid].locked == 1 and 0 or 1
	setElementData(intTable[uid].pickup, "intInfo", intTable[uid])
	triggerClientEvent("refreshIntPickupGUI", plr, intTable[uid])
	setPedAnimation(plr, "BD_Fire", "wash_up", -1, false, true, false, false)
	exports['mm_notifications']:alert(client, "info", string.format("%s lokal", intTable[uid].locked == 1 and "Zamknięto" or "Otwarto"))
end)

addEvent("enterInterior", true)
addEventHandler("enterInterior", root, enterInterior)

addEvent("locateInterior", true)
addEventHandler("locateInterior", root, locateInterior)

addEvent("exitInterior", true)
addEventHandler("exitInterior", root, exitInterior)

addEvent("updateDoorInfo", true)
addEventHandler("updateDoorInfo", root, updateDoorInfo)

addEventHandler("onResourceStart", resourceRoot, loadInteriors)
addEventHandler("onResourceStop", resourceRoot, unloadInteriors)

addEventHandler("onPlayerJoin", root, loadInteriorSounds)
