doorInfo = { map = {}, addons = {}, main ={} }
local doorTable = {}
local progress = 0

function getTableLength(tab)
	local count = 0
	for k in pairs(tab) do
		count = count + 1
	end
	return count
end


function createDoorInfoUI(doorTable)
	if isElement(doorInfo.window) then destroyElement(doorInfo.window) end

	doorInfo.window = guiCreateWindow(330, 203, 620, 314, "Zarządzanie drzwiami", false)
	guiWindowSetSizable(doorInfo.window, false)
	doorInfo.tabpanel = guiCreateTabPanel(9, 24, 601, 280, false, doorInfo.window)

	doorInfo.main.tab = guiCreateTab("Ogólne", doorInfo.tabpanel)
	doorInfo.main.name = guiCreateLabel(10, 10, 41, 23, "Nazwa:", false, doorInfo.main.tab)
	guiLabelSetColor(doorInfo.main.name, 255, 254, 254)
	doorInfo.main.desc = guiCreateLabel(10, 34, 41, 19, "Opis:", false, doorInfo.main.tab)
	doorInfo.main.nameEdit = guiCreateEdit(56, 10, 530, 24, doorTable.name, false, doorInfo.main.tab)
	doorInfo.main.descEdit = guiCreateMemo(56, 34, 530, 154, doorTable.description, false, doorInfo.main.tab)
	doorInfo.main.vehEnter = guiCreateLabel(10, 195, 107, 18, "Przejazd pojazdami:", false, doorInfo.main.tab)
	doorInfo.main.vehCheckbox = guiCreateCheckBox(122, 195, 15, 18, "", false, false, doorInfo.main.tab)
	guiCheckBoxSetSelected(doorInfo.main.vehCheckbox, doorTable.vehEnter == 1 and true or false)
	doorInfo.main.close = guiCreateButton(396, 221, 190, 24, "Zamknij", false, doorInfo.main.tab)
	doorInfo.main.save = guiCreateButton(196, 221, 190, 24, "Zapisz", false, doorInfo.main.tab)

	doorInfo.map.tab = guiCreateTab("Mapa", doorInfo.tabpanel)
	doorInfo.map.info = guiCreateLabel(10, 10, 584, 44, "Wklej zawartość pliku .map bezpośrednio z lokalnego edytora. Po wklejeniu wyświetli Ci się panel potwierdzający ilość obiektów oraz wybór markeru wejścia. W przypadku przekroczenia ilości możliwych obiektów do załadowania zostaniesz poinformowany.", false, doorInfo.map.tab)
	guiSetFont(doorInfo.map.info, "default-bold-small")
	guiLabelSetHorizontalAlign(doorInfo.map.info, "left", true)
	doorInfo.map.edit = guiCreateMemo(10, 58, 584, 150, "", false, doorInfo.map.tab)
	doorInfo.map.export = guiCreateButton(10, 222, 276, 24, "Wyeksportuj mapę", false, doorInfo.map.tab)
	doorInfo.map.save = guiCreateButton(318, 222, 276, 24, "Zapisz mapę", false, doorInfo.map.tab)

	doorInfo.addons.tab = guiCreateTab("Dodatki", doorInfo.tabpanel)
	doorInfo.addons.audio = guiCreateLabel(10, 12, 60, 24, string.format("Audio: Tak", doorTable.upgrades.audio and "Tak" or "Nie"), false, doorInfo.addons.tab)
	guiSetFont(doorInfo.addons.audio, "default-bold-small")
	--if doorTable.upgrades.audio then
		doorInfo.addons.audioEdit = guiCreateEdit(76, 10, 300, 24, doorTable.audioLink, false, doorInfo.addons.tab)
		doorInfo.addons.audioSave = guiCreateButton(383, 10, 208, 24, "Ustaw URL", false, doorInfo.addons.tab)
	---end
	doorInfo.addons.safe = guiCreateLabel(10, 36, 60, 24, string.format("Sejf: Tak", doorTable.upgrades.safe and "Tak" or "Nie"), false, doorInfo.addons.tab)
	guiSetFont(doorInfo.addons.safe, "default-bold-small")
	--if doorTable.upgrades.audio then
		doorInfo.addons.safeEdit = guiCreateEdit(76, 34, 300, 24, doorTable.safeCode, false, doorInfo.addons.tab)
		doorInfo.addons.safeSave = guiCreateButton(383, 34, 208, 24, "Zmień kod", false, doorInfo.addons.tab)
	---end
	doorInfo.addons.bell = guiCreateLabel(10, 60, 94, 24, string.format("Dzwonek: Tak", doorTable.upgrades.bell and "Tak" or "Nie"), false, doorInfo.addons.tab)
	guiSetFont(doorInfo.addons.bell, "default-bold-small")
	doorInfo.addons.cctv = guiCreateLabel(10, 84, 94, 24, string.format("Monitoring: Tak", doorTable.upgrades.cctv and "Tak" or "Nie"), false, doorInfo.addons.tab)
	guiSetFont(doorInfo.addons.cctv, "default-bold-small")
	doorInfo.addons.objects = guiCreateLabel(10, 108, 128, 24, string.format("Ilość obiektów: %d", doorTable.objects), false, doorInfo.addons.tab)
	guiSetFont(doorInfo.addons.objects, "default-bold-small")
	doorInfo.addons.avaible = guiCreateLabel(10, 132, 162, 24, string.format("Obiekty do dokupienia: %d", doorTable.moreObjects), false, doorInfo.addons.tab)
	guiSetFont(doorInfo.addons.avaible, "default-bold-small")
	if doorTable.moreObjects > 0 then
		doorInfo.addons.avaibleEdit = guiCreateEdit(178, 130, 198, 24, "0", false, doorInfo.addons.tab)
		doorInfo.addons.avaibleSave = guiCreateButton(384, 130, 208, 24, "Dokup", false, doorInfo.addons.tab)
		doorInfo.addons.info = guiCreateLabel(10, 156, 581, 90, "Każdy dodatkowy obiekt to koszt $1. Maksymalna ilość obiektów możliwych do wykupienia jest podana powyżej. Wpisz ile obiektów chcesz dokupić do swojego budynku. Pamiętaj! Tej operacji nie można cofnąć.", false, doorInfo.addons.tab)
        guiSetFont(doorInfo.addons.info, "default-bold-small")
        guiLabelSetHorizontalAlign(doorInfo.addons.info, "left", true)
	end

	showCursor(true)

	local function onClientGUIClick()
		if source == doorInfo.main.close then
			destroyElement(doorInfo.window)
			removeEventHandler("onClientGUIClick", root, onClientGUIClick)
			showCursor(false)
		elseif source == doorInfo.main.save then
			triggerServerEvent("updateDoorInfo", localPlayer, 1, doorTable.uid, {guiGetText(doorInfo.main.nameEdit), guiGetText(doorInfo.main.descEdit), not guiCheckBoxGetSelected(doorInfo.main.vehCheckbox) and 0 or 1})
			destroyElement(doorInfo.window)
			removeEventHandler("onClientGUIClick", root, onClientGUIClick)
			showCursor(false)
			return
		elseif source == doorInfo.addons.safeSave then
			triggerServerEvent("updateDoorInfo", localPlayer, 3, doorTable.uid, {guiGetText(doorInfo.addons.safeEdit)})
			destroyElement(doorInfo.window)
			removeEventHandler("onClientGUIClick", root, onClientGUIClick)
			showCursor(false)
			return
		elseif source == doorInfo.addons.audioSave then
			local url = guiGetText(doorInfo.addons.audioEdit)
			if not string.find(url, ".mp3", string.len(url) - 4, true) and not string.find(url, ".wav", string.len(url) - 4, true) and not string.find(url, ".ogg", string.len(url) - 4, true) and not string.find(url, ".riff", string.len(url) - 4, true) and not string.find(url, ".mod", string.len(url) - 4, true) and not string.find(url, ".xm", string.len(url) - 4, true) and not string.find(url, ".it", string.len(url) - 4, true) and not string.find(url, ".s3m", string.len(url) - 4, true) and not string.find(url, ".pls", string.len(url) - 4, true) and string.len(url) ~= 0 then return exports['mm_notifications']:alert("info" ,"Dostępne rozszerzenia to MP3, WAV, OGG, RIFF, MOD, XM, IT, S3M oraz PLS") end
			
			triggerServerEvent("updateDoorInfo", localPlayer, 2, doorTable.uid, {guiGetText(doorInfo.addons.audioEdit)})
			destroyElement(doorInfo.window)
			removeEventHandler("onClientGUIClick", root, onClientGUIClick)
			showCursor(false)
			return
		elseif source == doorInfo.map.save then
			local map = guiGetText(doorInfo.map.edit)
			local tmpFile = fileCreate("tmp.xml")
			fileWrite(tmpFile, map)
			fileClose(tmpFile)
			local xml = xmlLoadFile("tmp.xml")
			if not xml then return exports['mm_notifications']:alert("info", "Wystąpił błąd w trakcie ładowania obiektów") end
			local objects = xmlNodeGetChildren(xml)
			outputChatBox("1: "..getTableLength(objects))
			if getTableLength(objects) == 0 then return 	exports['mm_notifications']:alert('info', "Musisz wgrać obiekty") end
			for k,v in pairs(getElementsByType("player")) do
				if getElementData(v, "actualInterior") == doorTable.uid then
          exports['mm_notifications']:alert('info', "W lokalu znajdują się grcze - nie możesz załadować mapy")
					xmlUnloadFile(xml)
					fileDelete("tmp.xml")
					return 
				end
			end
			local entrance = {}
			for k, v in pairs(objects) do
				if xmlNodeGetName(v) == "marker" then
					if getTableLength(entrance) == 0 then
						local marker = xmlNodeGetAttributes(v)
						entrance = {x = marker.posX, y = marker.posY, z = marker.posZ}
						xmlDestroyNode(v)
					else
						xmlDestroyNode(v)
					end
				elseif xmlNodeGetName(v) == "pickup" or xmlNodeGetName(v) == "vehicle" then
					xmlDestroyNode(v)
				end
			end
			if getTableLength(entrance) == 0 then return exports['mm_notifications']:alert('info', "Nie ma określonego wejścia w interiorze")
      end
			xmlSaveFile(xml)
			if doorTable.objects >= getTableLength(xmlNodeGetChildren(xml)) then
		---		outputChatBox("2: "getTableLength(xmlNodeGetChildren(xml)))
				xmlUnloadFile(xml)
				local tmpFile = fileOpen("tmp.xml")
				triggerServerEvent("updateDoorInfo", localPlayer, 4, doorTable.uid, {fileRead(tmpFile, fileGetSize(tmpFile)), entrance})
				fileClose(tmpFile)
				fileDelete("tmp.xml")
				
				destroyElement(doorInfo.window)
				removeEventHandler("onClientGUIClick", root, onClientGUIClick)
				showCursor(false)
				return
			else
        exports['mm_notifications']:alert('info', string.format("Maksymalna ilość obiektów, w tym lokalu to %d", doorTable.objects))
				xmlUnloadFile(xml)
				fileDelete("tmp.xml")
				return
			end
		elseif source == doorInfo.addons.avaibleSave then
			local obj = tonumber(guiGetText(doorInfo.addons.avaibleEdit))
			if not obj or obj < 1 then return end
			if obj > doorTable.moreObjects then return end --- exports['mm_notifications']:alert('info', (string.format("Możesz maksymalnie dokupić %d obiektów", doorTable.moreObjects))
			if getPlayerMoney() < obj * 1 then return end --- exports['mm_notifications']:alert('info', (string.format("Nie masz wystarczającej ilości pieniędzy. Potrzebujesz $%d", obj * 1)) 
			doorTable.moreObjects = doorTable.moreObjects - obj
			doorTable.objects = doorTable.objects + obj
			guiSetText(doorInfo.addons.objects, string.format("Ilość obiektów: %d", doorTable.objects))
			guiSetText(doorInfo.addons.avaible, string.format("Obiekty do dokupienia: %d", doorTable.moreObjects))
			
			triggerServerEvent("updateDoorInfo", localPlayer, 5, doorTable.uid, {doorTable.moreObjects, doorTable.objects, obj * 1})
			destroyElement(doorInfo.window)
			removeEventHandler("onClientGUIClick", root, onClientGUIClick)
			showCursor(false)
			return
		end
	end
	addEventHandler("onClientGUIClick", root, onClientGUIClick)
end



function drawDX()
	if not getElementData(localPlayer, "enteringPickup") then return end
	dxDrawImage(416, 500, 448, 192, "assets/background.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawText(doorTable.name, 440, 516, 840, 550, tocolor(255, 255, 255, 255), 1.50, "default-bold", "left", "center", true, false, false, false, false)
	dxDrawText(doorTable.description, 563, 565, 840, 672, tocolor(255, 255, 255, 255), 1.00, "arial", "left", "top", true, true, false, false, false)
end

function enterInterior()
	if isChatBoxInputActive() then return end
	if isConsoleActive() then return end
	if isMainMenuActive() then return end
	
	if isPedInVehicle(localPlayer) and doorTable.vehEnter == 0 then return exports['mm_notifications']:alert("info", "Nie można tu przejechać pojazdem") end
	if doorTable.locked == 1 then return exports['mm_notifications']:alert("info", "Ten budynek jest zamknięty") end
	fadeCamera(false, 2)
	setTimer(function()
		removeEventHandler("onClientRender", root, drawDX)
	end, 1700, 1)
	setTimer(triggerServerEvent, 1800, 1, "enterInterior", localPlayer, doorTable.uid, localPlayer)
	setTimer(unbindKey, 1800, 1, "E", "down", enterInterior)
	setElementData(localPlayer, "enteringPickup", false)
	return
end

function exitInterior()
	if isChatBoxInputActive() then return end
	if isConsoleActive() then return end
	if isMainMenuActive() then return end
	
	if isPedInVehicle(localPlayer) and doorTable.vehEnter == 0 then return exports['mm_notifications']:alert("info", "Nie można tu przejechać pojazdem") end
	if doorTable.locked == 1 then return exports['mm_notifications']:alert("info", "Ten budynek jest zamknięty")  end
	setElementFrozen(localPlayer, true)
	fadeCamera(false, 2)
	local dim = getElementDimension(localPlayer)
	local int = getElementInterior(localPlayer)
	setTimer(triggerServerEvent, 1600, 1, "exitInterior", localPlayer, doorTable.uid)
	setTimer(unbindKey, 1600, 1, "E", "down", exitInterior)
	setTimer(function()
		for k,v in pairs(getElementsByType("object")) do
			if getElementDimension(v) == dim and getElementInterior(v) == int then
				destroyElement(v)
			end
		end
	end, 1700, 1)
	setElementData(localPlayer, "exitingPickup", false)
	if isElement(doorTable.intSound) then destroyElement(doorTable.intSound) end
	return
end

function createInteriorMap(map, x, y, z, url, uid)
	local time = getTickCount()
	if isElement(doorTable.exitPickup) then destroyElement(doorTable.exitPickup) end
	doorTable.exitPickup = createPickup(x, y, z, 3, 1239, 0)
	setElementDimension(doorTable.exitPickup, getElementDimension(localPlayer))
	setElementInterior(doorTable.exitPickup, getElementInterior(localPlayer))
	setElementData(doorTable.exitPickup, "exitPickup", true)
	setElementFrozen(localPlayer, false)
	
	for k,v in pairs(getElementsByType("object")) do
		if getElementDimension(v) == getElementDimension(localPlayer) and getElementInterior(v) == getElementInterior(localPlayer) then
			destroyElement(v)
		end
	end
	setElementData(localPlayer, "exitingPickup", false)
	if isElement(doorTable.intSound) then destroyElement(doorTable.intSound) end
	
	if not map or map == "" then return end
	local xml = fileCreate("tmp.xml")
	fileWrite(xml, map)
	fileClose(xml)
	local objects = xmlNodeGetChildren(xmlLoadFile("tmp.xml"))
	for k,v in pairs (objects) do
		if xmlNodeGetName(v) == "object" then
			local object = xmlNodeGetAttributes(v)
			local elem = createObject(object.model, object.posX, object.posY, object.posZ, object.rotX, object.rotY, object.rotZ)
			setElementDimension(elem, getElementDimension(localPlayer))
			setElementInterior(elem, getElementInterior(localPlayer))
			setElementCollisionsEnabled(elem, object.collisions == "true" and true or false)
			setObjectBreakable(elem, object.breakable == "true" and true or false)
			setObjectScale(elem, tonumber(object.scale))
			loadingProgress = k/#objects
			progress = interpolateBetween(0, 0, 0, 100, 0, 0, loadingProgress, "Linear")
		end
	end
	fileDelete("tmp.xml")
	outputChatBox(string.format("Czas ładowania %d obiektów: %dms", #objects, getTickCount() - time))
	setTimer(setElementFrozen, 2300, 1, localPlayer, false)
	setTimer(fadeCamera, 2000, 1, true)
	if url and doorTable.upgrades.audio then
		doorTable.intSound = playSound(url, true)
		setElementData(doorTable.intSound, "intID", uid)
	end
	if uid then
		doorTable.uid = uid
	end
	return
end

function onPickupHit(plr, dim)
	if plr ~= localPlayer or not dim then return end
	if getElementData(source, "intPickup") then
		doorTable = getElementData(source, "intInfo")
		
		removeEventHandler("onClientRender", root, drawDX)
		addEventHandler("onClientRender", root, drawDX)
		--outputChatBox("wejscie typ: "..getElementType(source))
		bindKey("E", "down", enterInterior)
		setElementData(localPlayer, "enteringPickup", source)
		return
	elseif getElementData(source, "exitPickup") then
		bindKey("E", "down", exitInterior)
		local x, y = getElementPosition(doorTable.exitPickup)
		setElementData(localPlayer, "exitingPickup", {x, y})
		return
	end
end

function onPickupLeave(plr, dim)
	if plr ~= localPlayer or not dim then return end
	if getElementData(source, "intPickup") then
		removeEventHandler("onClientRender", root, drawDX)
		unbindKey("E", "down", enterInterior)
		setElementData(localPlayer, "enteringPickup", false)
		return
	elseif source == doorTable.exitPickup then
		unbindKey("E", "down", exitInterior)
		setElementData(localPlayer, "exitingPickup", false)
		return
	end
end

function refreshIntPickupGUI(intTable)
	if not getElementData(localPlayer, "enteringPickup") and not getElementData(localPlayer, "actualInterior") then return end
	if getElementData(localPlayer, "enteringPickup") == intTable.pickup or getElementData(localPlayer, "actualInterior") == intTable.uid then
		local pickup = doorTable.pickup
		local intSound = doorTable.intSound
		doorTable = intTable
		doorTable.pickup = pickup
		doorTable.intSound = intSound
	end
end

function createInteriorEntrySound(url, posTable, uid)
	for k,v in pairs(getElementsByType("sound")) do
		if getElementData(v, "intID") == uid then
			destroyElement(v)
		end
	end
	doorTable.sound = playSound3D(url, posTable[1], posTable[2], posTable[3], true)
	setElementData(doorTable.sound, "intID", uid)
	setElementDimension(doorTable.sound, posTable[4])
	setElementInterior(doorTable.sound, posTable[5])
	setSoundMinDistance(doorTable.sound, 4)
	setSoundMaxDistance(doorTable.sound, 6)
	setSoundEffectEnabled(doorTable.sound, "reverb", true)
end

function destroyInteriorSound(uid)
	for k,v in pairs(getElementsByType("sound")) do
		if getElementData(v, "intID") == uid then
			destroyElement(v)
		end
	end
end

addEvent("createDoorInfoUI", true)
addEventHandler("createDoorInfoUI", root, createDoorInfoUI)

addEventHandler("onClientPickupHit", root, onPickupHit)
addEventHandler("onClientPickupLeave", root, onPickupLeave)

addEvent("destroyInteriorSound", true)
addEventHandler("destroyInteriorSound", root, destroyInteriorSound)

addEvent("createInteriorMap", true)
addEventHandler("createInteriorMap", root, createInteriorMap)

addEvent("createInteriorEntrySound", true)
addEventHandler("createInteriorEntrySound", root, createInteriorEntrySound)

addEvent("refreshIntPickupGUI", true)
addEventHandler("refreshIntPickupGUI", root, refreshIntPickupGUI)
