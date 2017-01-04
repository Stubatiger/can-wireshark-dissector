--
--
-- Extends the common CAN dissector of wireshark
-- with a CanIdentifier-Name
-- This script reads a table from a file with lines in the format:
-- [HexID] = [Name]
-- Example: 0x00000182 = Fensterheber
-- The file is named "NameMapping.txt" and needs to be in the same Plugins folder of wireshark
--

-- VARIABLES
local file = 'plugins\\2.2.1\\NameMapping.txt'

-- #################################################HELPER FUNCTIONS####################################################

-- takes a string and strips it from whitespace
function string:trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- splits a string the Python way
function string:split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
end

-- see a file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end
-- #####################################################################################################################
-- #####################################################################################################################
-- #####################################################################################################################


print("CAN PostDissector loaded")

--we need this field from the CAN dissector
local can_identifier = Field.new("can.id")

--Identifier to Name Mapping
local id_name = {}

-- read lines from file
local lines = lines_from(file)

-- dissect lines to HexID and CANID and put them into table
for n,l in pairs(lines) do
    local split = string.split(l,"=")
    local can_hex_id = string:trim(split[1])
    local can_name_id = string:trim(split[2])
    id_name[can_hex_id] = can_name_id
end

--declare our post dissector
local can_ext = Proto.new("can_ext", "My Can Protocol Extension PostDissector")

--our fields
local pf_idname = ProtoField.new("Name", "can_ext.name", ftypes.STRING)

can_ext.fields = { pf_idname}

-- dissect each packet
function can_ext.dissector(tvbuf,pktinfo,root)

    local can_id_hex = can_identifier()
    print(can_id_hex)
    local can_id_hex_string = tostring(can_id_hex)
    local can_id_name = id_name[can_id_hex_string]

    if can_id_name == nil then
        can_id_name = "UNKNOWN"
    end

    local tree = root:add(can_ext, "CAN Identifier Name")

    tree:add(pf_idname, can_id_name)

end

--register ourself
register_postdissector(can_ext)

