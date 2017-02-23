--
-- Created by IntelliJ IDEA.
-- User: simon
-- Date: 22.02.17
-- Time: 14:22
-- To change this template use File | Settings | File Templates.
--
-- constants
local sid_dict_description = {
    [0x10] = "Start Diagnostic Session",
    [0x20] = "Stop Diagnostic Session",
    [0x3E] = "Tester Present",
    [0x27] =  "Security Access",
    [0x11] =  "ECU Reset",
    [0x81] = "Start Comm",
    [0x82] = "Stop Comm",
    [0x28] = "Disable Normal Message Transm.",
    [0x29] = "Enable Normal Message Transm.",
    [0x85] = "Control DTC Setting",
    [0x83] = "Access Timing Parameters",
    [0x84] = "Network Configuration",

    [0x21] = "Read Data by Local Identifier",
    [0x22] = "Read Data by Common Identifier",
    [0x1A] = "Read ECU Identification",
    [0x23] = "Read Memory by Address",
    [0x3B] = "Write Data by Local Identifier",
    [0x2E] = "Write Data by Common Identifier",
    [0x3d] = "Write Memory by Address",
    [0x26] = "Set Data Rates",
    [0x2c] = "Dynamically define Data Identifier",

    [0x14] = "Clear Diagnostic Information",
    [0x13] = "Read Diagnostic Trouble Code",
    [0x12] = "Read Freeze Frame Data",
    [0x18] = "Read DTCs by Status",
    [0x17] = "Read Status of DTCs",

    [0x30] = "Input Output Control by Local ID",
    [0x2F] = "Input Output Control by Common ID",

    [0x31] = "Start Routine by Local Identifier",
    [0x32] = "Stop Routine by Local Identifier",
    [0x38] = "Start Routine by Address",
    [0x39] = "Stop Routine by Address",
    [0x33] = "Request Routine Results by Local ID",
    [0x3A] = "Request Routine Results by Address",

    [0x34] = "Request Download",
    [0x35] = "Request Upload",
    [0x36] = "Transfer Data",
    [0x37] = "Request Transfer Exit",

    [0x7F] = "Negative Response",
    [0x3F] = "Negative Response" -- Masked Negative Response
}

local sid_dict_group = {
    [0x10] = "Diagnostic and Communication Management",
    [0x20] = "Diagnostic and Communication Management",
    [0x3E] = "Diagnostic and Communication Management",
    [0x27] = "Diagnostic and Communication Management",
    [0x11] = "Diagnostic and Communication Management",
    [0x81] = "Diagnostic and Communication Management",
    [0x82] = "Diagnostic and Communication Management",
    [0x28] = "Diagnostic and Communication Management",
    [0x29] = "Diagnostic and Communication Management",
    [0x85] = "Diagnostic and Communication Management",
    [0x83] = "Diagnostic and Communication Management",
    [0x84] = "Diagnostic and Communication Management",

    [0x21] = "Data Transmission",
    [0x22] = "Data Transmission",
    [0x1A] = "Data Transmission",
    [0x23] = "Data Transmission",
    [0x3B] = "Data Transmission",
    [0x2E] = "Data Transmission",
    [0x3d] = "Data Transmission",
    [0x26] = "Data Transmission",
    [0x2c] = "Data Transmission",

    [0x14] = "Stored Data Transmission",
    [0x13] = "Stored Data Transmission",
    [0x12] = "Stored Data Transmission",
    [0x18] = "Stored Data Transmission",
    [0x17] = "Stored Data Transmission",

    [0x30] = "Input/Output Control",
    [0x2F] = "Input/Output Control",

    [0x31] = "Remote Activation of Routine",
    [0x32] = "Remote Activation of Routine",
    [0x38] = "Remote Activation of Routine",
    [0x39] = "Remote Activation of Routine",
    [0x33] = "Remote Activation of Routine",
    [0x3A] = "Remote Activation of Routine",

    [0x34] = "Upload/Download",
    [0x35] = "Upload/Download",
    [0x36] = "Upload/Download",
    [0x37] = "Upload/Download",

}

local response_codes = {
    [0x10] = "General reject",
    [0x11] = "Service or Subfunction not supported",
    [0x12] = "Service or Subfunction not supported",
    [0x7E] = "Service or Subfunction not supported",
    [0x7F] = "Service or Subfunction not supported",
    [0x13] = "Message length or format incorrect",
    [0x31] = "Out of range",
    [0x21] = "Busy - Repeat request",
    [0x78] = "Busy - Response pending",
    [0x22] = "Conditions not correct",
    [0x24] = "Request sentence error",
    [0x33] = "Security access denied",
    [0x35] = "Invalid key",
    [0x36] = "Exceed attempts",


}

local positive_response_mask = 0x40
local negative_response = 0x7F

-- fields
local length = ProtoField.new("Payload Length", "kwp2k.length", ftypes.UINT8,nil, base.DEC)
local sid = ProtoField.uint8("kwp2k.sid", "Service ID", base.HEX, sid_dict_description)
local sid_copy = ProtoField.uint8("kwp2k.sidcopy", "Service ID Copy", base.HEX, sid_dict_description)
local pid = ProtoField.new("Parameter Identifier", "kwp2k.pid", ftypes.BYTES)
local response = ProtoField.uint8("kwp2k.response","Response", base.HEX, sid_dict_description, 0xBF)
local response_data = ProtoField.new("Reponse Data", "kwp2k.rdata", ftypes.BYTES)
local response_code = ProtoField.uint8("kwp2k.rcode", "Response Code", base.HEX, response_codes)
local segmented = ProtoField.new("Segmented", "tp20.segment", ftypes.BOOLEAN)




-- declare dissector
local my_kwp_2000_dissector = Proto.new("kwp2k", "KWP2000")

my_kwp_2000_dissector.fields = {
    length,
    sid,
    sid_copy,
    pid,
    response_code,
    response_data,
    response,
    segmented
}

local partialBuffer = nil
pktState = {}

function my_kwp_2000_dissector.dissector(tvbuf,pktinfo,root)
    -- set the protocol column to show our protocol name
    pktinfo.cols.protocol:set("KWP2000")
    local pktlen = tvbuf:reported_length_remaining()
    local tree = root:add(my_kwp_2000_dissector, tvbuf:range(0,pktlen))

    --
    --pink 1
    set_color_filter_slot(1, "kwp2k && kwp2k.sidcopy") --negative responses

    --pink 2
    --set_color_filter_slot(2, "tp20.opcode == 0xc0 || tp20.opcode == 0xd0")

    --purple 1
    --set_color_filter_slot(3, "tp20.opcode == 0xc0 || tp20.opcode == 0xd0")

    --purple 2
    --set_color_filter_slot(4, "tp20.opcode == 0xc0 || tp20.opcode == 0xd0")

    --green 1
    --set_color_filter_slot(5, "kwp2k && kwp2k.response && !kwp2k.sidcopy")

    --green 2
    --set_color_filter_slot(6, "kwp2k && !kwp2k.response && !kwp2k.sidcopy")

    --green 3
    set_color_filter_slot(7, "kwp2k && kwp2k.response && !kwp2k.sidcopy") --positive response

    -- yellow 1
    set_color_filter_slot(8, "kwp2k && !kwp2k.response && !kwp2k.sidcopy && kwp2k.length") --requests

    --yellow 2
    --set_color_filter_slot(9, "tp20.opcode == 0xc0 || tp20.opcode == 0xd0")

    --gray
    set_color_filter_slot(10, "kwp2k && !kwp2k.length")  --segmented




    -- logic to handle segmented packets
    local state = pktState[pktinfo.number]

    if state ~= nil then
        -- we've already processed this packet
        if state.complete == true then
            pktinfo.cols.info = "Message [complete]"
            tree:add(segmented, false):set_generated()
            tvbuf = ByteArray.tvb(state.buffer, "Message Command")
        else
            pktinfo.cols.info = "Message [incomplete]"
            tree:add(segmented, true):set_generated()
            do return end -- nothing to do
        end
    else
        -- first time here, capture file has just been opened?
        state = {}
        if partialBuffer == nil then
            partialBuffer = tvbuf(0):bytes()
        else
            partialBuffer:append(tvbuf(0):bytes())
            tvbuf = ByteArray.tvb(partialBuffer, "Message") -- create new tvb for packet
        end

        if tvbuf:len() >= 2 then
            -- we have length field
            local expected_len = 2 + tvbuf(1,1):uint()
            if expected_len > tvbuf:len() then -- we don't have all the data we need yet
                state.complete = false
                pktState[pktinfo.number] = state
                do return end
            end
        else
            -- we don't have all of length field yet
            state.complete = false
            pktState[pktinfo.number] = state
            do return end
        end

        state.complete = true
        state.buffer = partialBuffer
        pktState[pktinfo.number] = state
        partialBuffer = nil
    end

    -- perform dissection of buf

    tree:add(length, tvbuf:range(1,1))  -- TODO starts from byte 0 or 1?

    local cur_sid = tvbuf:range(2,1):uint()
    pktlen = tvbuf:len()

    if cur_sid == negative_response then    -- negative response
        tree:add(response, tvbuf:range(2,1))
        tree:add(sid_copy, tvbuf:range(3,1))
        tree:add(response_code, tvbuf:range(4,1))
    elseif bit32.btest(cur_sid, positive_response_mask) then -- positive response (bit 6 is set)
        tree:add(response, tvbuf:range(2,1))
        tree:add(pid, tvbuf:range(3,pktlen-3))

    elseif sid_dict_description[cur_sid] ~= nil then    -- normal request
        tree:add(sid, tvbuf:range(2,1))
        tree:add(pid, tvbuf:range(3,pktlen-3))
    end

end

DissectorTable.new("tp20")
DissectorTable.get("tp20"):add(1, my_kwp_2000_dissector)

