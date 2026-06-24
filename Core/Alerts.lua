local addonName, ns = ...

local function MakeAlertFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(520, 120)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 220)
    frame:EnableMouse(false)
    frame:Hide()

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 0.78)
    bg:SetGradient("VERTICAL", CreateColor(0.15, 0.15, 0.15, 0.95), CreateColor(0.02, 0.02, 0.02, 0.98))

    local border = frame:CreateTexture(nil, "BORDER")
    border:SetAllPoints(frame)
    border:SetColorTexture(1, 0.2, 0.2, 0.95)
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -18)
    frame.title:SetTextColor(1, 0.9, 0.2)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOP", frame.title, "BOTTOM", 0, -10)
    frame.text:SetTextColor(1, 1, 1)
    frame.text:SetWidth(470)
    frame.text:SetJustifyH("CENTER")

    frame.timeLeft = 2.0
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.timeLeft = self.timeLeft - elapsed
        if self.timeLeft <= 0 then
            self:Hide()
        end
    end)

    return frame
end

function ns:InitAlerts()
    if self.alertFrame then
        return
    end

    self.alertFrame = MakeAlertFrame()
end

function ns:BigAlert(title, message, category, duration)
    if not self.alertFrame then
        self:InitAlerts()
    end

    if not self.alertFrame then
        return
    end

    self.alertFrame.title:SetText(title or "ALERT")
    self.alertFrame.text:SetText(message or "")
    self.alertFrame.timeLeft = duration or 2.0
    self.alertFrame:Show()

    if category == "DANGER" then
        self.alertFrame.title:SetTextColor(1, 0.2, 0.2)
        self.alertFrame.text:SetTextColor(1, 0.9, 0.8)
    elseif category == "CC" then
        self.alertFrame.title:SetTextColor(0.2, 0.9, 1)
        self.alertFrame.text:SetTextColor(0.9, 0.95, 1)
    elseif category == "SAFE" then
        self.alertFrame.title:SetTextColor(0.2, 1, 0.2)
        self.alertFrame.text:SetTextColor(0.85, 1, 0.85)
    else
        self.alertFrame.title:SetTextColor(1, 0.9, 0.2)
        self.alertFrame.text:SetTextColor(1, 1, 1)
    end

    if self.db and self.db.soundEnabled then
        PlaySound(128, "SFX")
    end
end
