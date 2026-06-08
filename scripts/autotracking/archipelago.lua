
require("scripts/autotracking/item_mapping")
require("scripts/autotracking/location_mapping")
require("scripts/autotracking/item_name_mapping")
require("scripts/autotracking/location_name_mapping")

CUR_INDEX = -1
--SLOT_DATA = nil

ALL_LOCATIONS = {}
SLOT_DATA = {}

ExcludedDuties = {}

MANUAL_CHECKED = true
ROOM_SEED = "default"
TROLL_PLAYER = false

if Highlight then
    HIGHLIGHT_LEVEL= {
        [0] = Highlight.Unspecified,
        [10] = Highlight.NoPriority,
        [20] = Highlight.Avoid,
        [30] = Highlight.Priority,
        [40] = Highlight.None,
        [100] = Highlight.Unspecified, --100 filler
        [101] = Highlight.Priority, --101 prog
        [102] = Highlight.NoPriority, --102 useful
        [103] = Highlight.Priority, --103 prog+useful
        [104] = Highlight.Avoid, --104 trap
        [105] = Highlight.Priority, --105 prog+trap
        [106] = Highlight.NoPriority, --106 useful+trap
        [107] = Highlight.Priority --107 prog+useful+trap
    }
end

Troll_Lookup = {
    ["solarcell"] = true,
    ["earthor"] = true,
}

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function LocationHandler(location)
    if MANUAL_CHECKED then
        local custom_storage_item = Tracker:FindObjectForCode("manual_location_storage").ItemState
        if not custom_storage_item then
            return
        end
        if Archipelago.PlayerNumber == -1 then -- not connected
            if ROOM_SEED ~= "default" then -- seed is from previous connection
                ROOM_SEED = "default"
                custom_storage_item.MANUAL_LOCATIONS["default"] = {}
            else -- seed is default
            end
        end
        local full_path = location.FullID
        if not custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED] then
            custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED] = {}
        end
        if location.AvailableChestCount < location.ChestCount then --add to list
            -- print("add to list")
            custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED][full_path] = location.AvailableChestCount
        else --remove from list of set back to max chestcount
            -- print("remove from list")
            custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED][full_path] = nil
        end
    end
    -- local custom_storage_item = Tracker:FindObjectForCode("manual_location_storage").ItemState
    -- print(dump_table(storage_item.ItemState.MANUAL_LOCATIONS))
    ForceUpdate() -- 
end

function ForceUpdate()
    local update = Tracker:FindObjectForCode("update")
    if update == nil then
        return
    end
    update.Active = not update.Active
end

function onClearHandler(slot_data)
    local clear_timer = os.clock()
    
    ScriptHost:RemoveWatchForCode("StateChange")
    -- Disable tracker updates.
    Tracker.BulkUpdate = true
    -- Use a protected call so that tracker updates always get enabled again, even if an error occurred.
    local ok, err = pcall(onClear, slot_data)
    -- Enable tracker updates again.
    if ok then
        -- Defer re-enabling tracker updates until the next frame, which doesn't happen until all received items/cleared
        -- locations from AP have been processed.
        local handlerName = "AP onClearHandler"
        local function frameCallback()
            ScriptHost:AddWatchForCode("StateChange", "*", StateChanged)
            ScriptHost:RemoveOnFrameHandler(handlerName)
            Tracker.BulkUpdate = false
            ForceUpdate()
            print(string.format("Time taken total: %.2f", os.clock() - clear_timer))
        end
        ScriptHost:AddOnFrameHandler(handlerName, frameCallback)
    else
        Tracker.BulkUpdate = false
        print("Error: onClear failed:")
        print(err)
    end
end

function preOnClear()
    PLAYER_ID = Archipelago.PlayerNumber or -1
	TEAM_NUMBER = Archipelago.TeamNumber or 0
    ExcludedDuties = {}
    
    if Archipelago.PlayerNumber > -1 then
        for key, _ in pairs(Troll_Lookup) do
            if string.find(string.lower(Archipelago:GetPlayerAlias(PLAYER_ID)), key, 1, true) ~= nil then
                TROLL_PLAYER = true
                break
            end
        end
        if #ALL_LOCATIONS > 0 then
            ALL_LOCATIONS = {}
        end
        for _, value in pairs(Archipelago.MissingLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        for _, value in pairs(Archipelago.CheckedLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end
        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
    end


    -- print(Archipelago.Seed)
    local seed_base = (Archipelago.Seed or tostring(#ALL_LOCATIONS)).."_"..Archipelago.TeamNumber.."_"..Archipelago.PlayerNumber
    if ROOM_SEED == "default" or ROOM_SEED ~= seed_base then -- seed is default or from previous connection

        ROOM_SEED = seed_base --something like 2345_0_12
        for _, custom_item_code in pairs({"manual_location_storage"}) do -- add more to the table if you created more storage cache items
            local custom_storage_item = Tracker:FindObjectForCode(custom_item_code).ItemState
            if custom_storage_item then
                if #custom_storage_item.MANUAL_LOCATIONS > 10 then
                    custom_storage_item.MANUAL_LOCATIONS[custom_storage_item.MANUAL_LOCATIONS_ORDER[1]] = nil
                    table.remove(custom_storage_item.MANUAL_LOCATIONS_ORDER, 1)
                end
                if custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED] == nil then
                    custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED] = {}
                    table.insert(custom_storage_item.MANUAL_LOCATIONS_ORDER, ROOM_SEED)
                end
            end
        end
    else -- seed is from previous connection
        -- do nothing
    end
end
-- ===== SLOT DATA PROCESSING =====
function processYaml(slot_data)
    --Add Sanity
        Tracker:FindObjectForCode("fatesanity").Active = slot_data["fatesanity"] == 1
        Tracker:FindObjectForCode("level_cap").AcquiredCount = slot_data["level_cap"]
        Tracker:FindObjectForCode("include_bozja").Active = slot_data["include_bozja"] == 1
        Tracker:FindObjectForCode("include_ocean_fishing").Active = slot_data["include_ocean_fishing"] == 1
        Tracker:FindObjectForCode("fishsanity").CurrentStage = slot_data["fishsanity"]
        Tracker:FindObjectForCode("include_unreasonable_fates").Active = slot_data["include_unreasonable_fates"] == 1
        Tracker:FindObjectForCode("allow_main_scenario_duties").Active = slot_data["allow_main_scenario_duties"] == 1
        Tracker:FindObjectForCode("include_pvp").Active = slot_data["include_pvp"] == 1
        Tracker:FindObjectForCode("duty_difficulty").CurrentStage = slot_data["duty_difficulty"]
        Tracker:FindObjectForCode("fates_per_zone").AcquiredCount = slot_data["fates_per_zone"]
        Tracker:FindObjectForCode("extra_dungeon_checks").AcquiredCount = slot_data["extra_dungeon_checks"]
        Tracker:FindObjectForCode("include_guildhests").Active = slot_data["include_guildhests"] == 1

     --Exclude Duty Check
        ExcludedDuties = slot_data["skipped_duties"]
    end

function checkCount(slot_data)    
    --FATE count
     Tracker:FindObjectForCode('@Middle La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Lower La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Middle La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Eastern La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Western La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Upper La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Outer La Noscea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Central Shroud/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@East Shroud/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@South Shroud/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@North Shroud/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Central Thanalan/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Western Thanalan/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Eastern Thanalan/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Southern Thanalan/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Northern Thanalan/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Mor Dhona/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Coerthas Central Highlands/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Coerthas Western Highlands/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Sea of Clouds/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Dravanian Forelands/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Churning Mists/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Dravanian Hinterlands/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Azys Lla/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Fringes/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Peaks/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Lochs/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Ruby Sea/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Yanxia/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Azim Steppe/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Lakeland/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Kholusia/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Amh Araeng/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Il Mheg/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Raktika Greatwood/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@The Tempest/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Labyrinthos/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Thavnair/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Garlemald/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Mare Lamentorum/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Elpis/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Ultima Thule/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Urqopacha/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Kozamauka/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Yak Tel/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Shaaloani/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Heritage Found/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     Tracker:FindObjectForCode('@Living Memory/FATEs/FATEs').AvailableChestCount = slot_data["fates_per_zone"]
     
     --Dungeon count
     Tracker:FindObjectForCode('@Western La Noscea/Sastasha/Sastasha').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Central Shroud/The Tam-Tara Deepcroft/The Tam-Tara Deepcroft').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Western Thanalan/Copperbell Mines/Copperbell Mines').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Eastern Thanalan/Halatali/Halatali').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@South Shroud/The Thousand Maws of Toto-Rak/The Thousand Maws of Toto-Rak').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Central Shroud/Haukke Manor (Dungeon)/Haukke Manor').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Eastern La Noscea/Brayfloxs Longstop/Brayfloxs Longstop').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Southern Thanalan/The Sunken Temple of Qarn/The Sunken Temple of Qarn').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Central Thanalan/Cutters Cry/Cutters Cry').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Central Highlands/The Stone Vigil/The Stone Vigil').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Central Highlands/Dzemael Darkhold/Dzemael Darkhold').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Central Highlands/The Aurum Vale/The Aurum Vale').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Northern Thanalan/Castrum Meridianum/Castrum Meridianum').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Northern Thanalan/The Praetorium/The Praetorium').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Upper La Noscea/The Wanderers Palace/The Wanderers Palace').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@South Shroud/Amdapor Keep/Amdapor Keep').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Western La Noscea/Pharos Sirius/Pharos Sirius').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Western Thanalan/Copperbell Mines/Copperbell Mines (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Central Shroud/Haukke Manor (Dungeon)/Haukke Manor (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@South Shroud/The Lost City of Amdapor/The Lost City of Amdapor').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Eastern Thanalan/Halatali/Halatali (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Eastern La Noscea/Brayfloxs Longstop/Brayfloxs Longstop (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Lower La Noscea/Hullbreaker Isle/Hullbreaker Isle').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Central Shroud/The Tam-Tara Deepcroft/The Tam-Tara Deepcroft (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Central Highlands/The Stone Vigil/The Stone Vigil (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Central Highlands/Snowcloak (Dungeon)/Snowcloak').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Western La Noscea/Sastasha/Sastasha (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Southern Thanalan/The Sunken Temple of Qarn/The Sunken Temple of Qarn (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Mor Dhona/The Keeper of the Lake/The Keeper of the Lake').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Upper La Noscea/The Wanderers Palace/The Wanderers Palace (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@South Shroud/Amdapor Keep/Amdapor Keep (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Western Highlands/The Dusk Vigil/The Dusk Vigil').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Forelands/Sohm Al/Sohm Al').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Foundation/The Aery/The Aery').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Foundation/The Vault/The Vault').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Hinterlands/The Great Gubal Library/The Great Gubal Library').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Azys Lla/The Aetherochemical Research Facility/The Aetherochemical Research Facility').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Sea of Clouds/Neverreap/Neverreap').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Azys Lla/The Fractal Continuum/The Fractal Continuum').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Hinterlands/Saint Mociannes Arboretum/Saint Mociannes Arboretum').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Limsa Lominsa Upper Decks/Pharos Sirius (Hard)/Pharos Sirius (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Hinterlands/The Antitower/The Antitower').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@South Shroud/The Lost City of Amdapor/The Lost City of Amdapor (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Churning Mists/Sohr Khai/Sohr Khai').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Lower La Noscea/Hullbreaker Isle/Hullbreaker Isle (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Coerthas Central Highlands/Xelphatol/Xelphatol').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Hinterlands/The Great Gubal Library/The Great Gubal Library (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@East Shroud/Baelsars Wall/Baelsars Wall').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Churning Mists/Sohm Al (Hard)/Sohm Al (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Limsa Lominsa Lower Decks/The Sirensong Sea/The Sirensong Sea').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Ruby Sea/Shisui of the Violet Tides/Shisui of the Violet Tides').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Azim Steppe/Bardams Mettle/Bardams Mettle').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Yanxia/Doma Castle (Dungeon)/Doma Castle').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Peaks/Castrum Abania/Castrum Abania').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Lochs/Ala Mhigo/Ala Mhigo').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Kugane/Kugane Castle/Kugane Castle').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Rhalgrs Reach/The Temple of the Fist/The Temple of the Fist').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Lochs/The Drowned City of Skalla/The Drowned City of Skalla').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Ruby Sea/Hells Lid (Dungeon)/Hells Lid').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Azys Lla/The Fractal Continuum/The Fractal Continuum (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Yanxia/The Swallows Compass/The Swallows Compass').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Yanxia/The Burn/The Burn').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Hinterlands/Saint Mociannes Arboretum/Saint Mociannes Arboretum (Hard)').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Lochs/Eorzean Alliance Headquarters/The Ghimlyt Dark').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Lakeland/Holminster Switch/Holminster Switch').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Il Mheg/Dohn Mheg/Dohn Mheg').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Raktika Greatwood/The Qitana Ravel/The Qitana Ravel').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Amh Araeng/Malikahs Well/Malikahs Well').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Kholusia/Mt. Gulg/Mt. Gulg').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Tempest/Amaurot/Amaurot').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Crystarium/The Twinning/The Twinning').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Tempest/Akadaemia Anyder/Akadaemia Anyder').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Kholusia/Anamnesis Anyder/Anamnesis Anyder').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Lakeland/The Grand Cosmos/The Grand Cosmos').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Eulmore/The Heroes Gauntlet/The Heroes Gauntlet').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@The Dravanian Hinterlands/Matoyas Relict/Matoyas Relict').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Uldah Steps of Nald/Paglthan/Paglthan').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Thavnair/The Tower of Zot/The Tower of Zot').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Garlemald/The Tower of Babil/The Tower of Babil').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Thavnair/Vanaspati/Vanaspati').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Elpis/Ktisis Hyperboreia/Ktisis Hyperboreia').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Labyrinthos/The Aitiascope/The Aitiascope').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Ultima Thule/The Dead Ends/The Dead Ends').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Mare Lamentorum/Smileton/Smileton').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Ultima Thule/The Stigma Dreamscape/The Stigma Dreamscape').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Thavnair/Alzadaals Legacy/Alzadaals Legacy').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Thavnair/The Fell Court of Troia/The Fell Court of Troia').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Garlemald/Lapis Manalis/Lapis Manalis').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Old Sharlayan/The Aetherfont/The Aetherfont').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Mare Lamentorum/The Red Moon/The Lunar Subterrane').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Central Thanalan/The Sildihn Subterrane/The Sildihn Subterrane').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Kugane/Mount Rokkon/Mount Rokkon').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Thavnair/Aloalo Island/Aloalo Island').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Tuliyollal/Ihuykatumu/Ihuykatumu').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Urqopacha/Worqor Zormor/Worqor Zormor').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Yak Tel/The Skydeep Cenote/The Skydeep Cenote').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Shaaloani/Vanguard/Vanguard').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Heritage Found/Origenics/Origenics').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Living Memory/Meso Terminal/Alexandria').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Shaaloani/Tender Valley/Tender Valley').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Living Memory/The Strayborough Deadwalk/The Strayborough Deadwalk').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Heritage Found/Yuweyawata Field Station/Yuweyawata Field Station').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Solution Nine/The Underkeep/The Underkeep').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Living Memory/Meso Terminal/The Meso Terminal').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Living Memory/Mistwake/Mistwake').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Old Sharlayan/The Merchants Tale/The Merchants Tale').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
	 Tracker:FindObjectForCode('@Garlemald/The Clyteum/The Clyteum').AvailableChestCount = slot_data["extra_dungeon_checks"] +1
     end




function onClear(slot_data)
    MANUAL_CHECKED = false
    local custom_storage_item = Tracker:FindObjectForCode("manual_location_storage").ItemState
    if custom_storage_item == nil then
        CreateLuaManualStorageItem("manual_location_storage")
        custom_storage_item = Tracker:FindObjectForCode("manual_location_storage").ItemState
    end
    -- repeat that here for every cache-storage item you create just to be save
    
    preOnClear()
    
    ScriptHost:RemoveWatchForCode("StateChanged")
    ScriptHost:RemoveOnLocationSectionHandler("location_section_change_handler")
    SLOT_DATA = slot_data
    processYaml(slot_data)
    CUR_INDEX = -1
    -- reset locations
    for _, location_array in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_array) do
            if location then
                local location_obj = Tracker:FindObjectForCode(location)
                if location_obj then
                    if location:sub(1, 1) == "@" then
                        if custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED][location_obj.FullID] then
                            location_obj.AvailableChestCount = custom_storage_item.MANUAL_LOCATIONS[ROOM_SEED][location_obj.FullID]
                        else
                            location_obj.AvailableChestCount = location_obj.ChestCount
                        end
                    else
                        location_obj.Active = false
                    end
                end
            end
        end
    end
    -- reset items
    for _, item_array in pairs(ITEM_MAPPING) do
        for _, item_pair in pairs(item_array) do
            item_code = item_pair[1]
            item_type = item_pair[2]
            -- print("on clear", item_code, item_type)
            local item_obj = Tracker:FindObjectForCode(item_code)
            if item_obj then
                if item_obj.Type == "toggle" then
                    item_obj.Active = false
                elseif item_obj.Type == "progressive" then
                    item_obj.CurrentStage = 0
                elseif item_obj.Type == "consumable" then
                    if item_obj.MinCount then
                        item_obj.AcquiredCount = item_obj.MinCount
                    else
                        item_obj.AcquiredCount = 0
                    end
                elseif item_obj.Type == "progressive_toggle" then
                    item_obj.CurrentStage = 0
                    item_obj.Active = false
                end
            end
        end
    end
    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    SLOT_DATA = slot_data
    checkCount(slot_data)
    -- if Tracker:FindObjectForCode("autofill_settings").Active == true then
    --     autoFill(slot_data)
    -- end
    -- print(PLAYER_ID, TEAM_NUMBER)
    if Archipelago.PlayerNumber > -1 then
        if #ALL_LOCATIONS > 0 then
            ALL_LOCATIONS = {}
        end
        for _, value in pairs(Archipelago.MissingLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        for _, value in pairs(Archipelago.CheckedLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
    end
    ScriptHost:AddOnFrameHandler("load handler", OnFrameHandler)
    MANUAL_CHECKED = true
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local item = ITEM_MAPPING[item_id]
    if not item or not item[1] then
        new_id = ITEM_NAME_MAPPING[item_name]
        if new_id then
            item = ITEM_MAPPING[new_id]
        end
    end
    if not item or not item[1] then
        print(string.format("onItem: could not find item mapping for id %s", item_id))
        return
    end
    for _, item_pair in pairs(item) do
        item_code = item_pair[1]
        item_type = item_pair[2]
        local item_obj = Tracker:FindObjectForCode(item_code)
        if item_obj then
            if item_obj.Type == "toggle" then
                -- print("toggle")
                item_obj.Active = true
            elseif item_obj.Type == "progressive" then
                -- print("progressive")
                if item_obj.Active == true then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            elseif item_obj.Type == "consumable" then
                -- print("consumable")
                item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment * (tonumber(item_pair[3]) or 1)
            elseif item_obj.Type == "progressive_toggle" then
                -- print("progressive_toggle")
                if item_obj.Active then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            end
        else
            print(string.format("onItem: could not find object for code %s", item_code[1]))
        end
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    MANUAL_CHECKED = false
    local location_array = LOCATION_MAPPING[location_id]
    if not location_array or not location_array[1] then
        new_id = LOCATION_NAME_MAPPING[location_name]
        if new_id then
            location_array = LOCATION_MAPPING[new_id]
        end
    end
    if not location_array or not location_array[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end

    for _, location in pairs(location_array) do
        local location_obj = Tracker:FindObjectForCode(location)
        -- print(location, location_obj)
        if location_obj then
            if location:sub(1, 1) == "@" then
                location_obj.AvailableChestCount = location_obj.AvailableChestCount - 1
            else
                location_obj.Active = true
            end
        else
            print(string.format("onLocation: could not find location_object for code %s", location))
        end
    end
    MANUAL_CHECKED = true
end

-- this Autofill function is meant as an example on how to do the reading from slotdata and mapping the values to 
-- your own settings
-- function autoFill()
--     if SLOT_DATA == nil  then
--         print("its fucked")
--         return
--     end
--     -- print(dump_table(SLOT_DATA))

--     mapToggle={[0]=0,[1]=1,[2]=1,[3]=1,[4]=1}
--     mapToggleReverse={[0]=1,[1]=0,[2]=0,[3]=0,[4]=0}
--     mapTripleReverse={[0]=2,[1]=1,[2]=0}

--     slotCodes = {
--         map_name = {code="", mapping=mapToggle...}
--     }
--     -- print(dump_table(SLOT_DATA))
--     -- print(Tracker:FindObjectForCode("autofill_settings").Active)
--     if Tracker:FindObjectForCode("autofill_settings").Active == true then
--         for settings_name , settings_value in pairs(SLOT_DATA) do
--             -- print(k, v)
--             if slotCodes[settings_name] then
--                 item = Tracker:FindObjectForCode(slotCodes[settings_name].code)
--                 if item.Type == "toggle" then
--                     item.Active = slotCodes[settings_name].mapping[settings_value]
--                 else 
--                     -- print(k,v,Tracker:FindObjectForCode(slotCodes[k].code).CurrentStage, slotCodes[k].mapping[v])
--                     item.CurrentStage = slotCodes[settings_name].mapping[settings_value]
--                 end
--             end
--         end
--     end
-- end

function OnNotify(key, value, old_value)
    print("OnNotify", key, value, old_value)
    if value ~= old_value and key == HINTS_ID then
        Tracker.BulkUpdate = true
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if hint.status == 0 then
                    UpdateHints(hint.location, 100+hint.item_flags)
                else
                    UpdateHints(hint.location, hint.status)
                end
            end
        end
        Tracker.BulkUpdate = false
    end
end

function OnNotifyLaunch(key, value)
    if key == HINTS_ID then
        Tracker.BulkUpdate = true
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if hint.status == 0 then
                    UpdateHints(hint.location, 100+hint.item_flags)
                else
                    UpdateHints(hint.location, hint.status)
                end
            end
        end
        Tracker.BulkUpdate = false
    end
end

function UpdateHints(locationID, status) -->
    if Highlight then
         --print(locationID, status)
        local location_table = LOCATION_MAPPING[locationID]
        for _, location in ipairs(location_table) do
            if location:sub(1, 1) == "@" then
                local obj = Tracker:FindObjectForCode(location)

                if obj then
                    if TROLL_PLAYER and HIGHLIGHT_LEVEL[status] == Highlight.Avoid then
                        obj.Highlight = HIGHLIGHT_LEVEL[30]
                    else
                        obj.Highlight = HIGHLIGHT_LEVEL[status]
                    end
                else
                    print(string.format("No object found for code: %s", location))
                end
            end
        end
    end
end


-- ScriptHost:AddWatchForCode("settings autofill handler", "autofill_settings", autoFill)
-- Archipelago:AddClearHandler("clear handler", onClearHandler)
-- Archipelago:AddItemHandler("item handler", onItem)
-- Archipelago:AddLocationHandler("location handler", onLocation)

-- Archipelago:AddSetReplyHandler("notify handler", OnNotify)
-- Archipelago:AddRetrievedHandler("notify launch handler", OnNotifyLaunch)



--doc
--hint layout
-- {
--     ["receiving_player"] = 1,
--     ["class"] = Hint,
--     ["finding_player"] = 1,
--     ["location"] = 67361,
--     ["found"] = false,
--     ["item_flags"] = 2, --bitflag --> 0=filler, 1=progression, 2=useful, 4=trap
--     ["status"] = 40, --bitflag --> 0=Unspecified, 10=NoPriority, 20=Avoid, 30=Priority, 40=None
--     ["entrance"] = ,
--     ["item"] = 66062,
-- } 
