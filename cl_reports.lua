
function HasReport(reportId)
    if not Config or not Config.Reports then return false end
    for _, report in pairs(Config.Reports) do
        if report.Id == reportId then
            return true
        end
    end
    return false
end
