-- ============================================
-- JOMIDAR ADMIN – QBOX BOOTSTRAP
-- ============================================

local Framework = 'qbox'

CreateThread(function()
    if GetResourceState('qbx_core') ~= 'started' then
        print('^1[JOMIDAR ADMIN]^7 qbx_core is NOT started – admin disabled')
        return
    end

    print('^2[JOMIDAR ADMIN]^7 Running on QBOX')
end)

-- Helper (use this everywhere)
function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end
