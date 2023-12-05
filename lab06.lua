#!/user/bin/lua5.3

local lgi = require('lgi')
local drv = require('luasql.postgres')

local env = drv.postgres()
local con = env:connect('host=pg.spb-kit.online port=54321 user=student password=stud_pass dbname=g21_zotov')

local gtk = lgi.require("Gtk", "3.0")
local pixbuf = lgi.GdkPixbuf.Pixbuf

local bld = gtk.Builder()
bld:add_from_file("lab06.glade")

local obj = bld.objects

local function up_list()
	local cur = con:execute('select id, name, value, image from lab06.items order by id ASC;')
	
	obj.recs:clear()
	while true do
		local row = cur:fetch({}, '*a')
		if row == nil then break end
	
		pic = pixbuf.new_from_file(row['image'])
	
		iter = obj.recs:append()
		obj.recs[iter] = {[1] = row['id'], [2] = row['name'], [3] = row['value'], [4] = pic}
	end
	cur:close()	
end

local tab = {
	['close' ] = gtk.main_quit,
	
	['add'   ] = function ()
		local name = obj.name.text
		local val = tonumber(obj.val.text)
		local img = obj.img:get_active_iter()
		
		if img == nil then return end
		local imgfile = obj.imgs[img][2]
		local sql = string.format("insert into lab06.items (name, value, image) values ('%s', %d, '%s');", name, val, imgfile)
		local cur = con:execute(sql)
		
		up_list()
	end,
	
	['remove'] = function ()
		local mdl, iter = obj.act:get_selected()
		if mdl == nil then return end
		local id = obj.recs[iter][1]

		local sql = string.format("delete from lab06.items where id = %d;", id)
		cur = con:execute(sql)
		
		up_list()
	end,
	
	['find'  ] = function ()
		local name = obj.filt.text
		
		if name == "" then 
			up_list()
		
		else
			local cur = con:execute(string.format("select id, name, value, image from lab06.items where name = '%s' order by id ASC;", name))
			obj.recs:clear()
			while true do
				local row = cur:fetch({}, '*a')
				if row == nil then break end
	
				pic = pixbuf.new_from_file(row['image'])
	
				iter = obj.recs:append()
				obj.recs[iter] = {[1] = row['id'], [2] = row['name'], [3] = row['value'], [4] = pic}
			end
		end
	end
}
bld:connect_signals(tab)

obj.add.on_clicked = tab['add']
obj.remove.on_clicked = tab['remove']
obj.find.on_clicked = tab['find']

up_list()

obj.wnd.on_destroy = gtk.main_quit
obj.wnd:show_all()
gtk.main()

con:close()
env:close()
