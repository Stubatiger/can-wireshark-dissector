--
-- Created by IntelliJ IDEA.
-- User: Simon
-- Date: 05.12.2016
-- Time: 20:29
-- To change this template use File | Settings | File Templates.
--


--TP2.0 Message Types

-- broadcast,
-- fixed length of 7 bytes
-- Byte     Description
-- 0        Logical Address of destination module
-- 1        Opcode: 0x23 = Broadcast Request, 0x24 = Broadcast Response
--
-- 2        KWP Data	KWP2000 SID and parameters
-- 3
-- 4
-- 5
--
-- 6        Response Request, 0x00 = Response Expected, 0x55 or 0xAA = No Response Expected
local tp_logical_addr = ProtoField.new("Destination Logical Address", "tp20.laddr", ftypes.UINT8, nil,base.HEX)
local tp_bc_opcode_dict = {
        [0x23] = "Broadcast Request",
        [0x24] = "Broadcast Response",
}
local tp_bc_opcode = ProtoField.new("Broadcast Opcode", "tp20.opcode", ftypes.UINT8,nil, base.HEX)
local tp_bc_kwp_data = ProtoField.new("KWP Data", "tp20.bc.kwpdata", ftypes.BYTES)

-- channel setup: Fixed Length of 7 Bytes
-- The channel setup request message should be sent from CAN ID 0x200 and the response will sent
-- with CAN ID 0x200 + the destination modules logical address e.g. for the engine control unit (0x01)
-- the response would be 0x201.
-- The communication then switches to using the CAN IDs which were negotiated during channel setup.
--
--
-- Byte     Description
-- 0        Dest: 	Logical address of destination module, e.g. 0x01 for the engine control unit
-- 1        OpCode:  0xC0 = Setup request, 0xD0	= Positive response, 0xD6..0xD8	= Negative response
-- 2        RX ID:  Tells destination module which CAN ID to listen to
-- 3        RX PREF: RX ID Prefix:
-- 4        TX ID: Tells destination module which CAN ID to transmit fro
-- 5        TX Pref: TX ID Prefix
-- 6        V:  	0x0	= CAN ID is valid, 0x1	= CAN ID is invalid
-- 7        App	Application type:  seems to always be 0x01 (maybe only for KWP)
--
--
-- -- -
local tp_cs_opcode_dict = {
    [0xC0] = "Setup request",
    [0xD0] = "Positive Response",
    [0xD6] = "Negative Response",
    [0xD7] = "Negative Response",
    [0xD8] = "Negative Response",
}

local tp_cs_opcode = ProtoField.uint8("tp20.opcode", "Op-Code", base.HEX, tp_cs_opcode_dict)

local tp_cs_rx = ProtoField.new("Receiver", "tp20.cs.rx", ftypes.UINT16,nil, base.HEX)
local tp_cs_rx_id = ProtoField.new("Receiver ID", "tp20.cs.rxid", ftypes.UINT8,nil, base.HEX, 0x00FF)
local tp_cs_rx_pref = ProtoField.new("Receiver Pref", "tp20.cs.rxpref", ftypes.UINT8,nil, base.HEX, 0xFF00)

local tp_cs_tx = ProtoField.new("Transceiver", "tp20.cs.tx", ftypes.UINT16,nil, base.HEX)
local tp_cs_tx_id = ProtoField.new("Transceiver ID", "tp20.cs.txid", ftypes.UINT16,nil, base.HEX, 0x00FF)
local tp_cs_tx_pref = ProtoField.new("Transceiver Pref", "tp20.cs.txpref", ftypes.UINT16,nil, base.HEX, 0xFF00)

local tp_cs_app_type = ProtoField.new("Application Type", "tp20.cs.atype", ftypes.UINT8,nil, base.HEX)

-- channel parameters: 1Byte or 6 Byte
-- It is used to setup parameters for an open channel and to send test, break and disconnect signals
-- You should send a parameters request straight after channel setup using the CAN IDs negotiated.
--
-- Byte Description
-- 0    OpCode: 0xA3 = Channel test, response is same as parameters response. Used to keep channel alive, 0xA4 = Break, receiver discards all data since last ACK, 0xA8 =	Disconnect, channel is no longer open. Receiver should reply with a disconnect
--
--
-- Byte     Description
-- 0        OpCode: 0xA0 = parameters request, used for destination module to initiator, 0xA1	Parameters respsonse, used for initiator to destination module
-- 1        BS: Block size, number of packets to send before expecting a ACK response
-- 2        T1	Timing parameter 1, time to wait for ACK. T1 should be greater than 4*T3
-- 3        T2	Timing parameter 2, always 0xFF
-- 4        T3	Timing parameter 3, interval between two packets
-- 5        T4	Timing parameter 4, always 0xFF
--
--  #TODO Timeing Parameters
--
local tp_cp_opcode_dict = {
    [0xA0] = "Parameters request",
    [0xA1] = "Parameters response",
    [0xA3] = "Channel test",
    [0xA4] = "Break",
    [0xA8] = "Disconnect",
}

local tp_cp_opcode = ProtoField.uint8("tp20.opcode", "Op-Code", base.HEX, tp_cp_opcode_dict)
local tp_cp_blocksize = ProtoField.new("Block Size", "tp20.cp.bs", ftypes.UINT8,nil, base.DEC)

local timing_dict = {
    [0x00] = "0.1ms",
    [0x01] = "1ms",
    [0x02] = "10ms",
    [0x03] = "100ms",
}

local tp_cp_timing = ProtoField.new("Timing", "tp20.cp.timing", ftypes.UINT32,nil, base.HEX)
local tp_cp_timing_t1_units = ProtoField.uint32("tp20.cp.t1u","Timing Parameter 1 units", base.HEX, timing_dict, 0xC0000000)
local tp_cp_timing_t1_scale = ProtoField.new("Timing Parameter 1 scale", "tp20.cp.t1s", ftypes.UINT32,nil, base.DEC, 0x3F000000)
local tp_cp_timing_t2 = ProtoField.new("Timing Parameter 2", "tp20.cp.t2", ftypes.UINT32,nil, base.HEX, 0x00FF0000)
local tp_cp_timing_t3_units = ProtoField.uint32("tp20.cp.t3u","Timing Parameter 3 units", base.HEX, timing_dict, 0x0000C000)
local tp_cp_timing_t3_scale = ProtoField.new("Timing Parameter 3 scale", "tp20.cp.t3s", ftypes.UINT32,nil, base.DEC, 0x00003F00)
local tp_cp_timing_t4 = ProtoField.new("Timing Parameter 4", "tp20.cp.t4", ftypes.UINT32,nil, base.HEX, 0x000000FF)

-- -- -
-- data transmission.
-- The data transmission type has a length of 2 to 8 bytes. It is used for the transmission of actual data/payload bytes.
-- Data transmission should only occur after channel setup and parameter negotiation.
--
-- Byte     Description
-- 0 	0x0	Waiting for ACK, more packets to follow (i.e. reached max block size value as specified above)
--      0x1	Waiting for ACK, this is last packet
--      0x2	Not waiting for ACK, more packets to follow
--      0x3	Not waiting for ACK, this is last packet
--      0xB	ACK, ready for next packet
--      0x9	ACK, not ready for next packet
-- 1    Sequence number, increments up to 0xF then back to 0x0
-- 2    Payload	KWP2000 payload. The first 2 bytes of the first packet sent contain the length of the message
-- 3
-- 4
-- -- -

local tp_dt_opcode_dict = {
    [0x0] = "Waiting for ACK, more packets to follow",
    [0x1] = "Waiting for ACK, this is last packet",
    [0x2] = "Not waiting for ACK, more packets to follow",
    [0x3] = "Not waiting for ACK, this is last packet",
    [0xB] = "ACK, ready for next packet",
    [0x9] = "ACK, not ready for next packet",
}

local tp_dt_opcode = ProtoField.uint8("tp20.opcode", "Op-Code", base.HEX, tp_dt_opcode_dict, 0xF0)
local tp_dt_seq_nr = ProtoField.new("Sequence Number", "tp20.dt.seqnr", ftypes.UINT8,nil, base.DEC, 0x0F)
local tp_dt_payload = ProtoField.new("Payload", "tp20.dt.payload", ftypes.BYTES)

--local tp_dt_kwp_sid = ProtoField.new("KWP SID", "tp20.dt.sid", ftypes.UINT8,nil, base.HEX)
--local tp_dt_kwp_para = ProtoField.new("KWP Parameter", "tp20.dt.para", ftypes.UINT8,nil, base.HEX)
--local tp_dt_length = ProtoField.new("Data Length", "tp20.dt.length", ftypes.UINT8,nil, base.DEC)
--General
local tp_mtype = ProtoField.new("Message Type", "tp20.mtype", ftypes.STRING)

--
local my_tp_20_dissector = Proto.new("tp20", "TP-2.0")

--TODO add IDentifier and Logical Address
--we need this field from the CAN dissector
--local can_identifier = Field.new("can.id")
--local tree = root:add(my_iso_tp_subdissector, tvbuf:range(0,pktlen))
-- Retrieve the CAN identifier
--local can_id_hex = can_identifier()
--local can_id_hex_string = tostring(can_id_hex)

my_tp_20_dissector.fields = {
    tp_logical_addr,
    tp_bc_opcode,
    tp_bc_kwp_data,
    tp_cs_opcode,
    tp_cs_rx,
    tp_cs_rx_id,
    tp_cs_rx_pref,
    tp_cs_tx,
    tp_cs_tx_id,
    tp_cs_tx_pref,
    tp_cs_app_type,
    tp_cp_opcode,
    tp_cp_blocksize,
    tp_cp_timing,
    tp_cp_timing_t1_units,
    tp_cp_timing_t1_scale,
    tp_cp_timing_t2,
    tp_cp_timing_t3_units,
    tp_cp_timing_t3_scale,
    tp_cp_timing_t4,
    tp_dt_opcode,
    tp_dt_seq_nr,
    tp_dt_payload,
    tp_mtype
}




function my_tp_20_dissector.dissector(tvbuf,pktinfo,root)

    -- set the protocol column to show our protocol name
    pktinfo.cols.protocol:set("TP-2.0")

    --colorize packets
    set_color_filter_slot(2, "!kwp2k && (tp20.opcode == 0xc0 || tp20.opcode == 0xd0 || tp20.opcode == 0xa0 || tp20.opcode == 0xa1 || tp20.opcode == 0xa3)") --channel setup
    set_color_filter_slot(6, "!kwp2k && tp20.opcode == 0xb")   --ack
    set_color_filter_slot(9, "tp20.opcode == 0xa8")  --disconnect

    local pktlen = tvbuf:reported_length_remaining()

    if pktlen == 7 then
        --Packet could be Broadcast or Channel Setup
        local op_code = tvbuf:range(1,1):uint()

        if tp_bc_opcode_dict[op_code] ~= nil then
            local tree = root:add(my_tp_20_dissector, tvbuf:range(0,pktlen))
            tree:add(tp_logical_addr, tvbuf:range(0,1))
            tree:add(tp_bc_opcode, tvbuf:range(1,1))
            tree:add(tp_bc_kwp_data, tvbuf:range(2,4))
            tree:add(tp_mtype, "Broadcast"):set_generated()

            do return end

        elseif tp_cs_opcode_dict[op_code] ~= nil then
            local tree = root:add(my_tp_20_dissector, tvbuf:range(0,pktlen))
            tree:add(tp_logical_addr, tvbuf:range(0,1))
            tree:add(tp_cs_opcode, tvbuf:range(1,1))

            local receiver_tree = tree:add_le(tp_cs_rx, tvbuf:range(2,2))
            receiver_tree:add(tp_cs_rx_id, tvbuf:range(2,2))
            receiver_tree:add(tp_cs_rx_pref, tvbuf:range(2,2))

            local transceiver_tree = tree:add_le(tp_cs_tx, tvbuf:range(4,2))
            transceiver_tree:add(tp_cs_tx_id, tvbuf:range(4,2))
            transceiver_tree:add(tp_cs_tx_pref, tvbuf:range(4,2))

            tree:add(tp_cs_app_type, tvbuf:range(6,1))
            tree:add(tp_mtype, "Channel Setup"):set_generated()
            do return end

        end
    end

    if pktlen == 6  then
        local op_code = tvbuf:range(0,1):uint()

        if tp_cp_opcode_dict[op_code] ~= nil then

            local tree = root:add(my_tp_20_dissector, tvbuf:range(0,pktlen))
            tree:add(tp_cp_opcode, tvbuf:range(0,1))
            tree:add(tp_cp_blocksize, tvbuf:range(1,1))
            local timing_tree = tree:add(tp_cp_timing, tvbuf:range(2,4))
            timing_tree:add(tp_cp_timing_t1_units, tvbuf:range(2,4))
            timing_tree:add(tp_cp_timing_t1_scale, tvbuf:range(2,4))
            timing_tree:add(tp_cp_timing_t2, tvbuf:range(2,4))
            timing_tree:add(tp_cp_timing_t3_units, tvbuf:range(2,4))
            timing_tree:add(tp_cp_timing_t3_scale, tvbuf:range(2,4))
            timing_tree:add(tp_cp_timing_t4, tvbuf:range(2,4))
            tree:add(tp_mtype, "Channel Parameters"):set_generated()
            do return end

        end
    end

    if pktlen == 1 then
        local op_code = tvbuf:range(0,1):uint()
        if tp_cp_opcode_dict[op_code] ~= nil then
            local tree = root:add(my_tp_20_dissector, tvbuf:range(0,pktlen))
            tree:add(tp_cp_opcode, tvbuf:range(0,1))
            tree:add(tp_mtype, "Channel Parameters"):set_generated()
            do return end
        end

        -- packet has to be data type
        local tree = root:add(my_tp_20_dissector, tvbuf:range(0,pktlen))
        tree:add(tp_dt_opcode, tvbuf:range(0,1))
        tree:add(tp_mtype, "Data Transmission"):set_generated()
        do return end
    end


    -- packet has to be of data type

    local tree = root:add(my_tp_20_dissector, tvbuf:range(0,pktlen))
    tree:add(tp_dt_opcode, tvbuf:range(0,1))
    tree:add(tp_dt_seq_nr, tvbuf:range(0,1))
    tree:add(tp_dt_payload, tvbuf:range(1,pktlen-1))
    tree:add(tp_mtype, "Data Transmission"):set_generated()

    local mydissectortable = DissectorTable.get("tp20")
    mydissectortable:try(1,tvbuf:range(1,pktlen-1):tvb(),pktinfo,root)

end


DissectorTable.get("can.subdissector"):add(0, my_tp_20_dissector)