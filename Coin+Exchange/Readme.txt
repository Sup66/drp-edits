All you have to do is to replace the files following the folder path.

After this you'll have to set your exchange points in cfg/item_transformers.lua like this.


   {
    name="Coin Exchange", -- menu name
    r=50,g=15,b=255, -- color
    max_units=100000,
    units_per_minute=100000,
    x=246.50698852539,y=222.37257385254,z=106.2868270874, --coords (Pacific Bank)
    radius=1, height=1.5, -- area
    recipes = {
      ["Change Coin"] = { -- action name
        description="Buy Euro with $", -- action description
        in_money=5, -- $ taken per unit
	in_vipmoney=0, -- Euros taken per unit
        out_money=0, --$ earned
        out_vipmoney=1, -- Euros earned per unit
        reagents={}, -- items taken per unit
        products={}
      }
	 }
  },
