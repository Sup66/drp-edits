
local cfg = {}

-- start wallet/bank values
cfg.open_wallet = 2000
cfg.open_bank = 1000
cfg.open_vipmoney = 0

cfg.display_css = [[
.div_money{
  position: absolute;
  top: 35px;
  right: 10px;
  font-size: 30px;
  font-family: Pricedown;
  color: #FFFFFF;
  text-shadow: rgb(0, 0, 0) 1px 0px 0px, rgb(0, 0, 0) 0.533333px 0.833333px 0px, rgb(0, 0, 0) -0.416667px 0.916667px 0px, rgb(0, 0, 0) -0.983333px 0.133333px 0px, rgb(0, 0, 0) -0.65px -0.75px 0px, rgb(0, 0, 0) 0.283333px -0.966667px 0px, rgb(0, 0, 0) 0.966667px -0.283333px 0px;
}
.div_bmoney{
  position: absolute;
  top: 63px;
  right: 10px;
  font-size: 30px;
  font-family: Pricedown;
  color: #FFFFFF;
  text-shadow: rgb(0, 0, 0) 1px 0px 0px, rgb(0, 0, 0) 0.533333px 0.833333px 0px, rgb(0, 0, 0) -0.416667px 0.916667px 0px, rgb(0, 0, 0) -0.983333px 0.133333px 0px, rgb(0, 0, 0) -0.65px -0.75px 0px, rgb(0, 0, 0) 0.283333px -0.966667px 0px, rgb(0, 0, 0) 0.966667px -0.283333px 0px;
}
.div_vipmoney{
  position: absolute;
  top: 91px;
  right: 10px;
  font-size: 30px;
  font-family: Pricedown;
  color: #FFFFFF;
  text-shadow: rgb(0, 0, 0) 1px 0px 0px, rgb(0, 0, 0) 0.533333px 0.833333px 0px, rgb(0, 0, 0) -0.416667px 0.916667px 0px, rgb(0, 0, 0) -0.983333px 0.133333px 0px, rgb(0, 0, 0) -0.65px -0.75px 0px, rgb(0, 0, 0) 0.283333px -0.966667px 0px, rgb(0, 0, 0) 0.966667px -0.283333px 0px;
}
  .div_money .symbol{

  content: url('https://i.imgur.com/m3JHLY0.png'); 
 
}

  .div_bmoney .symbol{
  content: url('https://i.imgur.com/k48xHdW.png');
  
}

  .div_vipmoney .symbol{

  content: url('https://i.imgur.com/b7PK76e.png');
}  
]]

return cfg
