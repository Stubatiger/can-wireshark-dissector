--
-- Created by IntelliJ IDEA.
-- User: Simon
-- Date: 30.11.2016
-- Time: 17:50
-- To change this template use File | Settings | File Templates.
--


--TODO reaad SIDs from File

local my_uds_subdissector = Proto.new("uds", "UDS")
print("myUDS Created")


-- create a protocol field (but not register it yet)
--ProtoField.new(name, abbr, type, [voidstring], [base], [mask], [descr])
--ProtoField.new   ("Authoritative", "mydns.flags.authoritative", ftypes.BOOLEAN, nil, 16, 0x0400, "is the response authoritative?")
local uds_sid = ProtoField.new("SID", "uds.sid", ftypes.UINT8, nil,base.HEX,0x00,"SID")
local uds_req_ack_bit = ProtoField.new("AckBit", "uds.ackbit", ftypes.BOOLEAN, nil,base.HEX,0x80,"Acknowledge Bit")
