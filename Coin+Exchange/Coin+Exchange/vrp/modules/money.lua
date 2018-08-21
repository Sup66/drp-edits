local lang = vRP.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

MySQL.createCommand("vRP/money_tables", [[
CREATE TABLE IF NOT EXISTS vrp_user_moneys(
  user_id INTEGER,
  wallet INTEGER,
  bank INTEGER,
  vipmoney INTEGER,
  CONSTRAINT pk_user_moneys PRIMARY KEY(user_id),
  CONSTRAINT fk_user_moneys_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
]])

MySQL.createCommand("vRP/money_init_user","INSERT IGNORE INTO vrp_user_moneys(user_id,wallet,bank,vipmoney) VALUES(@user_id,@wallet,@bank,@vipmoney)")
MySQL.createCommand("vRP/get_money","SELECT wallet,bank,vipmoney FROM vrp_user_moneys WHERE user_id = @user_id")
MySQL.createCommand("vRP/set_money","UPDATE vrp_user_moneys SET wallet = @wallet, bank = @bank, vipmoney = @vipmoney WHERE user_id = @user_id")

-- init tables
MySQL.execute("vRP/money_tables")

-- load config
local cfg = module("cfg/money")

-- API

-- get money
-- cbreturn nil if error
function vRP.getMoney(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.wallet or 0
  else
    return 0
  end
end

--get vipmoney
function vRP.getVipMoney(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.vipmoney or 0
  else
    return 0
  end
end

-- set money
function vRP.setMoney(user_id,value)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.wallet = value
  end

  -- update client display
  local source = vRP.getUserSource(user_id)
  if source ~= nil then
    vRPclient.setDivContent(source,{"money",lang.money.display({value})})
  end
end

-- set vipmoney
function vRP.setVipMoney(user_id,value)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.vipmoney = value
  end

  -- update client display
  local source = vRP.getUserSource(user_id)
  if source ~= nil then
    vRPclient.setDivContent(source,{"vipmoney",lang.money.vipdisplay({value})})
  end
end

-- try a payment
-- return true or false (debited if true)
function vRP.tryPayment(user_id,amount)
  local money = vRP.getMoney(user_id)
  if money >= amount then
    vRP.setMoney(user_id,money-amount)
    return true
  else
    return false
  end
end

--(VIP)try a payment(VIP)
-- return true or false (debited if true)
function vRP.tryVipPayment(user_id,amount)
  local vipmoney = vRP.getVipMoney(user_id)
  if vipmoney >= amount then
    vRP.setVipMoney(user_id,vipmoney-amount)
    return true
  else
    return false
  end
end

-- give money
function vRP.giveMoney(user_id,amount)
  local money = vRP.getMoney(user_id)
  vRP.setMoney(user_id,money+amount)
end

-- give vipmoney
function vRP.giveVipMoney(user_id,amount)
  local money = vRP.getVipMoney(user_id)
  vRP.setVipMoney(user_id,money+amount)
end
--[[
--Conversie

function vRP.convertVipMoney(user_id,sumabani)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
	if sumabani%100000 == 0 then
	 local sloboz = sumabani/100000
	 tmp.vipmoney = sloboz
	 while sloboz
	 tmp.wallet = tmp.wallet-100000
	 sloboz = sloboz-1
	end
	
	end
end
--]]
-- get bank money
function vRP.getBankMoney(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.bank or 0
  else
    return 0
  end
end

-- set bank money
function vRP.setBankMoney(user_id,value)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.bank = value
  end
  local source = vRP.getUserSource(user_id)
  if source ~= nil then
    vRPclient.setDivContent(source,{"bmoney",lang.money.bdisplay({value})})
  end
end

-- give bank money
function vRP.giveBankMoney(user_id,amount)
  if amount > 0 then
    local money = vRP.getBankMoney(user_id)
    vRP.setBankMoney(user_id,money+amount)
  end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function vRP.tryWithdraw(user_id,amount)
  local money = vRP.getBankMoney(user_id)
  if amount > 0 and money >= amount then
    vRP.setBankMoney(user_id,money-amount)
    vRP.giveMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function vRP.tryDeposit(user_id,amount)
  if amount > 0 and vRP.tryPayment(user_id,amount) then
    vRP.giveBankMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function vRP.tryFullPayment(user_id,amount)
  local money = vRP.getMoney(user_id)
  if money >= amount then -- enough, simple payment
    return vRP.tryPayment(user_id, amount)
  else  -- not enough, withdraw -> payment
    if vRP.tryWithdraw(user_id, amount-money) then -- withdraw to complete amount
      return vRP.tryPayment(user_id, amount)
    end
  end

  return false
end

-- events, init user account if doesn't exist at connection
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  MySQL.execute("vRP/money_init_user", {user_id = user_id, wallet = cfg.open_wallet, bank = cfg.open_bank, vipmoney = cfg.open_vipmoney}, function(affected)
    -- load money (wallet,bank,vipmoney)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
      MySQL.query("vRP/get_money", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
          tmp.bank = rows[1].bank
          tmp.wallet = rows[1].wallet
		  tmp.vipmoney = rows[1].vipmoney
        end
      end)
    end
  end)
end)

-- save money on leave
AddEventHandler("vRP:playerLeave",function(user_id,source)
  -- (wallet,bank,vipmoney)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp and tmp.wallet ~= nil and tmp.bank ~= nil and tmp.vipmoney ~= nil then
    MySQL.execute("vRP/set_money", {user_id = user_id, wallet = tmp.wallet, bank = tmp.bank, vipmoney = tmp.vipmoney})
  end
end)

-- save money (at same time that save datatables)
AddEventHandler("vRP:save", function()
  for k,v in pairs(vRP.user_tmp_tables) do
    if v.wallet ~= nil and v.bank ~= nil and v.vipmoney ~= nil then
      MySQL.execute("vRP/set_money", {user_id = k, wallet = v.wallet, bank = v.bank, vipmoney = v.vipmoney})
    end
  end
end)

-- money hud
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- add money display
    vRPclient.setDiv(source,{"money",cfg.display_css,lang.money.display({vRP.getMoney(user_id)})})
	vRPclient.setDiv(source,{"bmoney",cfg.display_css,lang.money.bdisplay({vRP.getBankMoney(user_id)})})
	vRPclient.setDiv(source,{"vipmoney",cfg.display_css,lang.money.vipdisplay({vRP.getVipMoney(user_id)})})
  end
end)

local function ch_give(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id ~= nil then
          -- prompt number
          vRP.prompt(player,lang.money.give.prompt(),"",function(player,amount)
            local amount = parseInt(amount)
            if amount > 0 and vRP.tryPayment(user_id,amount) then
              vRP.giveMoney(nuser_id,amount)
              vRPclient.notify(player,{lang.money.given({amount})})
              vRPclient.notify(nplayer,{lang.money.received({amount})})
            else
              vRPclient.notify(player,{lang.money.not_enough()})
            end
          end)
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end

-- add player give money to main menu
vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id ~= nil then
    local choices = {}
    choices[lang.money.give.title()] = {ch_give, lang.money.give.description()}

    add(choices)
  end
end)
