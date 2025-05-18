local micro = import("micro")
local config = import("micro/config")

function jsonfmt(bp)
	bp:Save()
    local filepath, _ = bp.Buf.AbsPath
    if filepath == "" then
        micro.InfoBar():Error("No file to format")
        return
    end

    local cmd = "yq -i " .. filepath
	local _, err = os.execute(cmd)
	if err ~= nil then
	    micro.InfoBar():Error(err)
	    return
	end
	bp.Buf:ReOpen()
end


function init()
    config.MakeCommand("jsonfmt", jsonfmt, config.NoComplete)
end
