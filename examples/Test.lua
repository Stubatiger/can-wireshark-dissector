--
-- Created by IntelliJ IDEA.
-- User: Simon
-- Date: 13.11.2016
-- Time: 17:25
-- To change this template use File | Settings | File Templates.
--

-- get all lines from a file, returns an empty list/table if the file does not exist
function print_dissector_tables()
  local dt = DissectorTable.list()

    for _,name in ipairs(dt) do
        print(name)
    end

end

function print_registered_dissectors()
    local t = Dissector.list()

    for _,name in ipairs(t) do
        print(name)
    end
end

local encap_tbl = DissectorTable.get("wtap_encap")

local can_subdissector_table = DissectorTable.get("can.subdissector")

print(can_subdissector_table)




