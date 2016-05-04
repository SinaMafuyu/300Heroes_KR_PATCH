include("../Data/Script/Common/include.lua")
include("../Data/Script/Common/window.lua")

--------聊天界面

---聊天栏
local chatpart_ui = nil
local chatImg = nil
local toggleImg = nil
local togglebtn = nil
local chatInput = nil
local chatshow = nil

--聊天输入框
local chatInputEdit = nil

local btn_chat = nil
local chat_ui = nil

local updownCount = 0
local lastToggleBtnPos = 115
local maxlines = 12

function InitRoomChat(wnd)
	--聊天栏
	chatpart_ui = CreateWindow(wnd.id, 355,477, 580, 208)
	chatImg = chatpart_ui:AddImage(path.."chatMessageBK_hall.png",-4,-2,580,208)
	chatImg:SetTouchEnabled(0)
	chatshow = chatpart_ui:AddChat(14,8,-4,-7,520,197,0xffbeb5ee)
	
	--滑动栏、滑动键
	toggleImg = chatpart_ui:AddImage(path.."toggleBK_main.png",554,20,16,164)
	togglebtn = toggleImg:AddButton(path.."toggleBTN1_main.png",path.."toggleBTN2_main.png",path.."toggleBTN3_main.png",0,lastToggleBtnPos,16,50)
	local ToggleT = toggleImg:AddImage(path.."TD1_main.png",0,-16,16,16)
	local ToggleD = toggleImg:AddImage(path.."TD1_main.png",0,164,16,16)
	
	XSetWindowFlag(togglebtn.id,1,1,0,lastToggleBtnPos)
	
	togglebtn:ToggleBehaviour(XE_ONUPDATE, 1)	
	togglebtn:ToggleEvent(XE_ONUPDATE, 1)
	
	togglebtn.script[XE_ONUPDATE] = function()
		if togglebtn._T == nil then
			togglebtn._T = 0
		end
		
		local L,T,R,B = XGetWindowClientPosition(togglebtn.id)
		if togglebtn._T ~= T then
			local id = chatshow.id
			if id ~= 0 then
				local curLines = XGetChatLineNum(id)
				local delta = curLines - maxlines
				
				local length = 0
				if delta > 0 then
					length = lastToggleBtnPos / delta
					
					local line = math.floor(((lastToggleBtnPos-T)/length)+0.5)
					if line < 0 then
						line = 0
					elseif line > delta then
						line = delta
					end
					
					if line > updownCount then
						XScrollChat(id,0,line-updownCount)
					elseif line < updownCount then
						XScrollChat(id,1,updownCount-line)
					end
					
					updownCount = line
					
					if updownCount==0 then
						XSetChatAutoScroll(id,1)
					else
						XSetChatAutoScroll(id,0)
					end
				end
			end
			togglebtn._T = T
		end		
	end

	XWindowEnableAlphaTouch(chatpart_ui.id)
	chatpart_ui:EnableEvent(XE_MOUSEWHEEL)
	chatpart_ui.script[XE_MOUSEWHEEL] = function()
		local id = chatshow.id
		if id ~= 0 then
			local curLines = XGetChatLineNum(id)
			local delta = curLines - maxlines
			
			local length = 0
			if delta > 0 then
				length = lastToggleBtnPos / delta
			else
				delta = 0
				length = 0
			end
			
			local updown  = XGetMsgParam0()
			if updown<0 then
				updownCount = updownCount-1
				if updownCount<0 then
					updownCount=0
				else
					XScrollChat(id,1,1)
				end
			else
				updownCount = updownCount+1
				if updownCount>delta then
					updownCount=delta
				else
					XScrollChat(id,0,1)
				end
			end
			
			if updownCount==0 then
				XSetChatAutoScroll(id,1)
			else
				XSetChatAutoScroll(id,0)
			end
			
			togglebtn:SetPosition(0,lastToggleBtnPos-length*updownCount)
			togglebtn._T = lastToggleBtnPos-length*updownCount
		end
	end
	
	--liaotianshurulan
	chatInputEdit = CreateWindow(wnd.id, 353,688,530,45)
	chatInput = chatInputEdit:AddEdit(path.."chatEdit_hall.png","","onRoomChatEnter","",15,10,10,530,35,0xffffffff,0xff000000,0,"")
	XEditSetMaxByteLength(chatInput.id,60)
	chatInput:SetDefaultFontText("聊天输入内容后按Enter键发送", 0xff303b4a)
		
	btn_chat = chatInputEdit:AddButton(path.."channelselect1_hall.png",path.."channelselect2_hall.png",path.."channelselect3_hall.png",534,1,39,42)
	btn_chat:AddFont("全体",15,8,2,-6,40,32,0xbeb5ee)

end

--聊天输入栏按Enter键发送函数到C++
function onRoomChatEnter(data)
	local msg = chatInput:GetEdit()
	XChatInputChangeChannel(6)
	XChatSendMsg(chatInput.id,data)
	chatInput:SetEdit("")
end

function AddRoomChatTextToLua(strChat)
	if chatshow ~= nil then
		chatshow:AddChatText(strChat)
		
		if updownCount > 0 then
			updownCount = updownCount + 1
			
			local id = chatshow.id
			if id ~= 0 then
				local curLines = XGetChatLineNum(id)
				local delta = curLines - maxlines
				
				local length = 0
				if delta > 0 then
					length = lastToggleBtnPos / delta
					togglebtn:SetPosition(0,lastToggleBtnPos-length*updownCount)
				end
			end
		end
	end
end

function SetRoomChatInputIsVisible(flag)
	if chatInputEdit ~= nil then
		if flag == 1  and chatInputEdit:IsVisible() == false then
			chatInput:SetVisible(1)
			chatInputEdit:SetVisible(1)
		elseif flag == 0  and chatInputEdit:IsVisible() == true then
			chatInput:SetVisible(0)
			chatInputEdit:SetVisible(0)
		end
	end
end

function SetRoomChatInputFocus(focus)
	if chatInput ~= nil then
		chatInput:SetFocus(focus)
	end
end

function SetTxtIntoRoomChatInput(txt)
	if chatInput ~= nil and chatInput:IsFocus() then
		chatInput:SetEdit(txt)
	end
end

function IsRoomChatInputFocus()
	if chatInput ~= nil then
		return chatInput:IsFocus()
	end
	
	return false
end

function ClearRoomChat()
	if chatshow ~= nil then
		chatshow:ClearChatText()
	end
		
	if chatInput~=nil then
		chatInput:SetEdit("")
	end
end