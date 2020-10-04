function AutoMail_OnLoad()
	b = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	b:SetText("Open All")
	b:SetScript("OnClick", AutoMail)
	b:Hide()
	
	cb = CreateFrame("CheckButton", "MyCheckBox", UIParent, "ChatConfigCheckButtonTemplate");
	cb:SetScript("OnClick", AutoMail_OnCheck)
	cb.tooltip = "Don't Delete Letters"
	cb:Hide()
end

function AutoMail_EventHandler(event)
	if event == "MAIL_SHOW" then
		b:SetParent("InboxFrame")
		b:SetPoint("TOP", "MailFrame", 0, -b:GetParent():GetHeight() / 12)
		b:SetSize(b:GetParent():GetWidth() / 4 , b:GetParent():GetHeight() / 20)
		b:Show()
		
		cb:SetParent("InboxFrame")
		cb:SetFrameLevel(cb:GetParent():GetFrameLevel() + 1)
		cb:SetPoint("TOP", "InboxFrame", cb:GetParent():GetWidth() / 4, -cb:GetParent():GetHeight() / 12)
		cb:SetSize(cb:GetParent():GetHeight() / 20 , cb:GetParent():GetHeight() / 20)
		cb:SetHitRectInsets(0,0,0,0)
		cb:Show()
	else 
		b:Hide()
		cb:Hide()
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
