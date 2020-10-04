function AutoMail_OnLoad()
	AutoMail_button = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	AutoMail_button:SetText("Open All")
	AutoMail_button:SetScript("OnClick", AutoMail)
	AutoMail_button:Hide()
	
	AutoMail_checkbox = CreateFrame("CheckButton", "MyCheckBox", UIParent, "ChatConfigCheckButtonTemplate");
	AutoMail_checkbox:SetScript("OnClick", AutoMail_OnCheck)
	AutoMail_checkbox.tooltip = "Don't Delete Letters"
	AutoMail_checkbox:Hide()
end

function AutoMail_EventHandler(event)
	if event == "MAIL_SHOW" then
		AutoMail_button:SetParent("InboxFrame")
		AutoMail_button:SetPoint("TOP", "InboxFrame", 0, -AutoMail_button:GetParent():GetHeight() / 12)
		AutoMail_button:SetSize(AutoMail_button:GetParent():GetWidth() / 4 , AutoMail_button:GetParent():GetHeight() / 20)
		AutoMail_button:Show()
		
		AutoMail_checkbox:SetParent("InboxFrame")
		AutoMail_checkbox:SetFrameLevel(AutoMail_checkbox:GetParent():GetFrameLevel() + 1)
		AutoMail_checkbox:SetPoint("TOP", "InboxFrame", AutoMail_checkbox:GetParent():GetWidth() / 4, -AutoMail_checkbox:GetParent():GetHeight() / 12)
		AutoMail_checkbox:SetSize(AutoMail_checkbox:GetParent():GetHeight() / 20 , AutoMail_checkbox:GetParent():GetHeight() / 20)
		AutoMail_checkbox:SetHitRectInsets(0,0,0,0)
		AutoMail_checkbox:Show()
	else 
		AutoMail_button:Hide()
		AutoMail_checkbox:Hide()
	end

end

-- open mail logic

automail_control = false
index = 1
mailid = 0
has_changed = false
start_shown = 0
delete_letters = true

function AutoMail_OnCheck()
	delete_letters = not delete_letters
end

function OpenAllMail()
	local shown, total = GetInboxNumItems()
	if shown < start_shown then
		has_changed = true
	end
	if shown - index + 1 == 0 then
		automail_control = false
		InboxGetMoreMail()
		if has_changed then
			AutoMail_wait(0.2, AutoMail)
		end
		return 0
	end
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(index);
	if not hasItem then
		hasItem = 0
	end
	if CODAmount > 0 then
		index = index + 1
		AutoMail_wait(0, OpenAllMail)
		return 0
	end
	if mailid == daysLeft then
		if hasItem + money == 0 and delete_letters then
			DeleteInboxItem(index)
		else
			index = index + 1
		end
	else
		mailid = daysLeft
		AutoLootMailItem(index)
	end
	AutoMail_wait(0.05 * (hasItem + 1), OpenAllMail)
end

function AutoMail()
	if automail_control then
		return 0
	end
	local shown, total = GetInboxNumItems()
	start_shown = shown
	automail_control = true
	index = 1
	OpenAllMail()
end


-- wait function below

local waitTable = {};
local waitFrame = nil;

function AutoMail_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end
