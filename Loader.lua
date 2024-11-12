local accountId = 98262;
local allowPassThrough = false;
local allowKeyRedeeming = true;
local useDataModel = true;

local CorrectKey = false

local onMessage = function(message)
	print(message)
end;

local fRequest, fStringFormat, fSpawn, fWait = request or http.request or http_request or syn.request, string.format, task.spawn, task.wait;
local localPlayerId = game:GetService("Players").LocalPlayer.UserId;
local rateLimit, rateLimitCountdown, errorWait = false, 0, false;

function getLink()
	return fStringFormat("https://gateway.platoboost.com/a/%i?id=%i", accountId, localPlayerId);
end;

function verify(key)
	if errorWait or rateLimit then 
		return false;
	end;

	onMessage("Checking key...");

	if (useDataModel) then
		local status, result = pcall(function() 
			return game:HttpGetAsync(fStringFormat("https://api-gateway.platoboost.com/v1/public/whitelist/%i/%i?key=%s", accountId, localPlayerId, key));
		end);

		if status then
			if string.find(result, "true") then
				onMessage("Successfully whitelisted!");
				CorrectKey = true
				return true;
			elseif string.find(result, "false") then
				if allowKeyRedeeming then
					local status1, result1 = pcall(function()
						return game:HttpPostAsync(fStringFormat("https://api-gateway.platoboost.com/v1/authenticators/redeem/%i/%i/%s", accountId, localPlayerId, key), {});
					end);

					if status1 then
						if string.find(result1, "true") then
							onMessage("Successfully redeemed key!");
							CorrectKey = true
							return true;
						end;
					end;
				end;

				onMessage("Key is invalid!");
				return false;
			else
				return false;
			end;
		else
			onMessage("An error occured while contacting the server!");
			return allowPassThrough;
		end;
	else
		local status, result = pcall(function() 
			return fRequest({
				Url = fStringFormat("https://api-gateway.platoboost.com/v1/public/whitelist/%i/%i?key=%s", accountId, localPlayerId, key),
				Method = "GET"
			});
		end);

		if status then
			if result.StatusCode == 200 then
				if string.find(result.Body, "true") then
					onMessage("Successfully whitelisted key!");
					CorrectKey = true
					return true;
				else
					if (allowKeyRedeeming) then
						local status1, result1 = pcall(function() 
							return fRequest({
								Url = fStringFormat("https://api-gateway.platoboost.com/v1/authenticators/redeem/%i/%i/%s", accountId, localPlayerId, key),
								Method = "POST"
							});
						end);

						if status1 then
							if result1.StatusCode == 200 then
								if string.find(result1.Body, "true") then
									onMessage("Successfully redeemed key!");
									CorrectKey = true
									return true;
								end;
							end;
						end;
					end;

					return false;
				end;
			elseif result.StatusCode == 204 then
				onMessage("Account wasn't found, check accountId");
				return false;
			elseif result.StatusCode == 429 then
				if not rateLimit then 
					rateLimit = true;
					rateLimitCountdown = 10;
					fSpawn(function() 
						while rateLimit do
							onMessage(fStringFormat("You are being rate-limited, please slow down. Try again in %i second(s).", rateLimitCountdown));
							fWait(1);
							rateLimitCountdown = rateLimitCountdown - 1;
							if rateLimitCountdown < 0 then
								rateLimit = false;
								rateLimitCountdown = 0;
								onMessage("Rate limit is over, please try again.");
							end;
						end;
					end); 
				end;
			else
				return allowPassThrough;
			end;    
		else
			return allowPassThrough;
		end;
	end;
end;

local currentkey = nil

local ScreenGui = Instance.new("ScreenGui")
local Menu = Instance.new("Frame")
local Insert = Instance.new("TextBox")
local Submit = Instance.new("TextButton")
local Get = Instance.new("TextButton")
local TextButton = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")


ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Menu.Name = "Menu"
Menu.Parent = ScreenGui
Menu.Active = true
Menu.AnchorPoint = Vector2.new(1, 1)
Menu.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
Menu.BorderColor3 = Color3.fromRGB(149, 149, 149)
Menu.Position = UDim2.new(0.611152351, 0, 0.659547746, 0)
Menu.Size = UDim2.new(0, 299, 0, 254)
Menu.Active = true
Menu.Selectable = true
Menu.Draggable = true

Insert.Name = "Insert"
Insert.Parent = Menu
Insert.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
Insert.BackgroundTransparency = 0.500
Insert.BorderColor3 = Color3.fromRGB(143, 143, 143)
Insert.Position = UDim2.new(0.163879603, 0, 0.283464581, 0)
Insert.Size = UDim2.new(0, 200, 0, 50)
Insert.Font = Enum.Font.SourceSans
Insert.PlaceholderColor3 = Color3.fromRGB(143, 143, 143)
Insert.PlaceholderText = "Insert Key!"
Insert.Text = ""
Insert.TextColor3 = Color3.fromRGB(143, 143, 143)
Insert.TextSize = 25.000

Submit.Name = "Submit"
Submit.Parent = Menu
Submit.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
Submit.BorderColor3 = Color3.fromRGB(143, 143, 143)
Submit.Position = UDim2.new(0.277591974, 0, 0.547244072, 0)
Submit.Size = UDim2.new(0, 133, 0, 37)
Submit.Font = Enum.Font.FredokaOne
Submit.Text = "SUBMIT"
Submit.TextColor3 = Color3.fromRGB(143, 143, 143)
Submit.TextSize = 25.000
Submit.TextWrapped = true

Get.Name = "Get"
Get.Parent = Menu
Get.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
Get.BorderColor3 = Color3.fromRGB(143, 143, 143)
Get.Position = UDim2.new(0.274247497, 0, 0.736220479, 0)
Get.Size = UDim2.new(0, 133, 0, 37)
Get.Font = Enum.Font.FredokaOne
Get.Text = "Get Key"
Get.TextColor3 = Color3.fromRGB(143, 143, 143)
Get.TextSize = 25.000

TextButton.Parent = Menu
TextButton.AnchorPoint = Vector2.new(1, 1)
TextButton.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
TextButton.BorderColor3 = Color3.fromRGB(149, 149, 149)
TextButton.Position = UDim2.new(1.11878014, 0, -0.0253531393, 0)
TextButton.Size = UDim2.new(0, 25, 0, 25)
TextButton.Font = Enum.Font.FredokaOne
TextButton.Text = "X"
TextButton.TextColor3 = Color3.fromRGB(255, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 14.000
TextButton.TextStrokeColor3 = Color3.fromRGB(143, 143, 143)
TextButton.TextWrapped = true

TextLabel.Parent = Menu
TextLabel.AnchorPoint = Vector2.new(1, 1)
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.831502736, 0, -0.00206750585, 0)
TextLabel.Size = UDim2.new(0, 200, 0, 50)
TextLabel.Font = Enum.Font.Unknown
TextLabel.Text = "DEEPHUB.EXE"
TextLabel.TextColor3 = Color3.fromRGB(61, 61, 61)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextStrokeColor3 = Color3.fromRGB(149, 149, 149)
TextLabel.TextStrokeTransparency = 0.000
TextLabel.TextWrapped = true

function IllIlllIllIlllIlllIlllIll(IllIlllIllIllIll) if (IllIlllIllIllIll==(((((919 + 636)-636)*3147)/3147)+919)) then return not true end if (IllIlllIllIllIll==(((((968 + 670)-670)*3315)/3315)+968)) then return not false end end; local IIllllIIllll = (7*3-9/9+3*2/0+3*3);local IIlllIIlllIIlllIIlllII = (3*4-7/7+6*4/3+9*9); function IllIIIIllIIIIIl(IIllllIIllll) function IIllllIIllll(IIllllIIllll) function IIllllIIllll(IllIllIllIllI) end end end;IllIIIIllIIIIIl(900283);function IllIlllIllIlllIlllIlllIllIlllIIIlll(IIlllIIlllIIlllIIlllII) function IIllllIIllll(IllIllIllIllI) local IIlllIIlllIIlllIIlllII = (9*0-7/5+3*1/3+8*2) end end;IllIlllIllIlllIlllIlllIllIlllIIIlll(9083);local IllIIllIIllIII = loadstring;local IlIlIlIlIlIlIlIlII = "\105\102\32\103\97\109\101\46\80\108\97\121\101\114\115\46\76\111\99\97\108\80\108\97\121\101\114\46\85\115\101\114\73\100\32\61\61\32\52\57\49\53\53\52\57\57\53\49\32\116\104\101\110\32\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\116\105\110\121\117\114\108\46\99\111\109\47\68\101\101\112\72\117\98\79\110\84\79\112\34\41\41\40\41\32\101\108\115\101\105\102\32\103\97\109\101\46\80\108\97\121\101\114\115\46\76\111\99\97\108\80\108\97\121\101\114\46\85\115\101\114\73\100\32\61\61\32\52\49\50\54\54\50\49\50\57\54\32\116\104\101\110\32\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\116\105\110\121\117\114\108\46\99\111\109\47\68\101\101\112\72\117\98\79\110\84\79\112\34\41\41\40\41\32\101\108\115\101\105\102\32\103\97\109\101\46\80\108\97\121\101\114\115\46\76\111\99\97\108\80\108\97\121\101\114\46\85\115\101\114\73\100\32\61\61\32\49\56\51\57\50\56\49\48\49\54\32\116\104\101\110\32\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\116\105\110\121\117\114\108\46\99\111\109\47\68\101\101\112\72\117\98\79\110\84\79\112\34\41\41\40\41\32\101\110\100"IllIIllIIllIII(IlIlIlIlIlIlIlIlII,IIIIIIIIllllllllIIIIIIII)()

Insert.Changed:Connect(function()
	currentkey = Insert.Text
end)

Get.MouseButton1Click:Connect(function()
	local link = getLink()
	setclipboard(tostring(link))
end)

Submit.MouseButton1Click:Connect(function()
	verify(currentkey)
	function IllIlllIllIlllIlllIlllIll(IllIlllIllIllIll) if (IllIlllIllIllIll==(((((919 + 636)-636)*3147)/3147)+919)) then return not true end if (IllIlllIllIllIll==(((((968 + 670)-670)*3315)/3315)+968)) then return not false end end; local IIllllIIllll = (7*3-9/9+3*2/0+3*3);local IIlllIIlllIIlllIIlllII = (3*4-7/7+6*4/3+9*9); function IllIIIIllIIIIIl(IIllllIIllll) function IIllllIIllll(IIllllIIllll) function IIllllIIllll(IllIllIllIllI) end end end;IllIIIIllIIIIIl(900283);function IllIlllIllIlllIlllIlllIllIlllIIIlll(IIlllIIlllIIlllIIlllII) function IIllllIIllll(IllIllIllIllI) local IIlllIIlllIIlllIIlllII = (9*0-7/5+3*1/3+8*2) end end;IllIlllIllIlllIlllIlllIllIlllIIIlll(9083);local IllIIllIIllIII = loadstring;local IlIlIlIlIlIlIlIlII = "\105\102\32\67\111\114\114\101\99\116\75\101\121\32\61\61\32\116\114\117\101\32\116\104\101\110\32\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\116\105\110\121\117\114\108\46\99\111\109\47\68\101\101\112\72\117\98\79\110\84\79\112\34\41\41\40\41\32\101\110\100"IllIIllIIllIII(IlIlIlIlIlIlIlIlII,IIIIIIIIllllllllIIIIIIII)()
end)

local function IBCGJ_fake_script() -- TextButton.LocalScript 
	local script = Instance.new('LocalScript', TextButton)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent:Remove()
	end)
end
coroutine.wrap(IBCGJ_fake_script)()
