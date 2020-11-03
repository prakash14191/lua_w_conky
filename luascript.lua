--[[This Lua script draws vertical bar indicators]]

require 'cairo'

function conky_main ()
	if conky_window == nil then return end

	local cs = cairo_xlib_surface_create (conky_window.display,
			conky_window.drawable, conky_window.visual, conky_window.width,
			conky_window.height)

	cr = cairo_create (cs)
	---------------------------------------------------
	RADIUS = 100
	Gx, Gy = 350, 350
	FONTSIZE = 20
	draw_hexagon_grid5(cr, 350, 350, RADIUS)
	draw_clock(cr, 350, 350, 0.7*RADIUS)
	put_centre_text(cr, 350, 330, FONTSIZE, conky_parse("${exec date '+%a, %b %d' }"))
	put_centre_text(cr, 350, 380, FONTSIZE, conky_parse("${exec date '+%R' }"))

	-- RAM Usage Hexagon (top right)
	ram = tonumber(conky_parse("${memperc}"))
	xc, yc = Gx + 1.5*RADIUS, Gy - RADIUS*math.sin(t)
	a, b = centre_to_corner(xc, yc, RADIUS)
	cairo_set_source_rgba (cr, 0, 1, 0, 0.3);
	fill_hexagon_h(cr, a + (100-ram)*RADIUS/100, b, ram*RADIUS/100)
	put_centre_text(cr, xc, yc - 2*FONTSIZE, FONTSIZE, "RAM:")
	put_centre_text(cr, xc, yc, FONTSIZE, ram .. "%")

	-- CPU Usage Hexagon (bottom right)
	cpu = tonumber(conky_parse("${cpu cpu0}"))
	xc, yc = Gx + 1.5*RADIUS, Gy + RADIUS*math.sin(t)
	a, b = centre_to_corner(xc, yc, RADIUS)
	cairo_set_source_rgba (cr, 0, 1, 0, 0.3);
	fill_hexagon_h(cr, a + (100-cpu)*RADIUS/100, b, cpu*RADIUS/100)
	put_centre_text(cr, xc, yc - 1.5*FONTSIZE, FONTSIZE, "CPU:")
	put_centre_text(cr, xc, yc, FONTSIZE, cpu .. "%")
	temp = conky_parse("${hwmon 1 temp 1}")
	put_centre_text(cr, xc, yc + 1.5*FONTSIZE, FONTSIZE, temp.. "°C")

	-- System Info (top left)
	xc, yc = Gx - 1.5*RADIUS, Gy - RADIUS*math.sin(t)
	a, b = centre_to_corner(xc, yc, RADIUS)
	name = conky_parse("${execi 86400 whoami}")
	sysinfo = conky_parse("${execi 86400  lsb_release -si }")
				.. " " .. conky_parse("${execi 86400 lsb_release -sr}")
	uptime = conky_parse("${uptime}")
	put_centre_text(cr, xc, yc - 2*FONTSIZE, FONTSIZE, name)
	put_centre_text(cr, xc, yc - FONTSIZE, FONTSIZE, "@")
	put_centre_text(cr, xc, yc , FONTSIZE, sysinfo)
	put_centre_text(cr, xc, yc + 1.5*FONTSIZE, FONTSIZE, uptime)



	---------------------------------------------------
	cairo_destroy (cr)
	cairo_surface_destroy (cs)
	cr = nil

end

function draw_clock(cr, xc, yc, radius)
	hr = os.date("%I")
	min = os.date("%M")
	angl_min = (2*math.pi/60)*min - math.pi/2
	angl_hr = (2*math.pi/12)*hr + (2*math.pi*min/720)- math.pi/2

	cairo_set_line_width (cr, 3);
	cairo_set_source_rgba (cr, 0, 0, 0, 1);
	cairo_arc (cr, xc, yc, radius, angl_min, angl_hr);
	cairo_stroke (cr);

	cairo_set_source_rgba (cr, 0, 0, 0.8, 0.1);
	cairo_arc (cr, xc, yc, 1.1*radius, 0, 2*math.pi);
	cairo_fill (cr);
	cairo_set_source_rgba (cr, 0.7, 0.7, 0.7, 0.2);
	cairo_arc (cr, xc, yc, 0.7*radius, 0, 2*math.pi);
	cairo_fill (cr);

	-- hours
	cairo_set_line_width (cr, 5);
	cairo_set_line_cap  (cr, CAIRO_LINE_CAP_ROUND);
	cairo_set_source_rgba (cr, 1, 1, 1, 1);
	cairo_arc (cr, xc, yc, 0.7*radius, angl_hr, angl_hr);
	cairo_line_to (cr, xc, yc);
	cairo_stroke(cr);

	-- mins
	cairo_set_source_rgba (cr, 0, 0, 1, 1);
	cairo_set_line_cap  (cr, CAIRO_LINE_CAP_ROUND);
	cairo_arc (cr, xc, yc, 1.1*radius, angl_min, angl_min);
	cairo_line_to (cr, xc, yc);
	cairo_stroke (cr);

end

function put_centre_text(cr, x, y, size, text)
	font = "Monospace"
	font_size = size
	local extents = cairo_text_extents_t:create()
	tolua.takeownership(extents)

	cairo_set_source_rgba (cr, 0, 0, 0, 1);
	cairo_select_font_face (cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, font_size)
	cairo_text_extents (cr, text, extents);
	cairo_move_to (cr, x-(extents.width / 2 + extents.x_bearing), y-(extents.height / 2 + extents.y_bearing))
	cairo_show_text (cr, text)

end

function fill_hexagon_h(cr, x, y, a)
	line_join = CAIRO_LINE_JOIN_ROUND
	cairo_move_to(cr, x, y)
	cairo_set_dash(cr, {10, 10, 10, 10}, 4, 5)
	cairo_line_to(cr, x + a*math.cos(math.pi/3), y - a*math.sin(math.pi/3))
	cairo_line_to(cr, x + a + a*math.cos(math.pi/3), y - a*math.sin(math.pi/3))
	cairo_line_to(cr, x + a + 2*a*math.cos(math.pi/3), y)
	cairo_line_to(cr, x + a + a*math.cos(math.pi/3), y + a*math.sin(math.pi/3))
	cairo_line_to(cr, x + a*math.cos(math.pi/3), y + a*math.sin(math.pi/3))
	cairo_set_line_join (cr, line_join)
	cairo_close_path(cr)
	cairo_fill(cr)
	cairo_set_dash(cr, {}, 0, 0)
end

function draw_hexagon_h(cr, x, y, a)
	line_join = CAIRO_LINE_JOIN_ROUND
	cairo_set_line_width(cr, 1)
	cairo_move_to(cr, x, y)
	cairo_set_dash(cr, {10, 10}, 2, 5)
	cairo_line_to(cr, x + a*math.cos(math.pi/3), y - a*math.sin(math.pi/3))
	cairo_line_to(cr, x + a + a*math.cos(math.pi/3), y - a*math.sin(math.pi/3))
	cairo_line_to(cr, x + a + 2*a*math.cos(math.pi/3), y)
	cairo_line_to(cr, x + a + a*math.cos(math.pi/3), y + a*math.sin(math.pi/3))
	cairo_line_to(cr, x + a*math.cos(math.pi/3), y + a*math.sin(math.pi/3))
	cairo_set_line_join (cr, line_join)
	cairo_close_path(cr)
	cairo_stroke(cr)
	cairo_set_dash(cr, {}, 0, 0)
end

function draw_hexagon_grid5(cr, xc, yc, a)
	t = math.pi/3
	x, y = xc - 2.5*a, yc - a*math.sin(t)
	radpat = cairo_pattern_create_radial (xc, yc, a, xc, yc, 2.5*a);
	cairo_pattern_add_color_stop_rgba (radpat, 0,  0.976, 0.941, 0.949, 0.09);
	cairo_pattern_add_color_stop_rgba (radpat, 0.3,  0.976, 0.941, 0.949, 0.55);
	cairo_pattern_add_color_stop_rgba (radpat, 0.6,  0.976, 0.941, 0.949, 0.35);
	cairo_pattern_add_color_stop_rgba (radpat, 0.9,  0.976, 0.941, 0.949, 0.7);

	draw_hexagon_h(cr, x, 					y, 					a)
	-- cairo_set_source_rgba (cr, 0.976, 0.941, 0.949, 0.09);
	cairo_set_source (cr, radpat);
	fill_hexagon_h(cr, x + 0.05*a, 					y,			0.95*a)
	cairo_set_source_rgba (cr, 0, 0, 0, 1);

	draw_hexagon_h(cr, x+a*(1+math.cos(t)), y+a*math.sin(t), 	a)

	draw_hexagon_h(cr, x+a*3, 				y, 					a)
	-- cairo_set_source_rgba (cr, 0.976, 0.941, 0.949, 0.09);
	cairo_set_source (cr, radpat);
	fill_hexagon_h(cr, x+a*3.05, 				y, 				0.95*a)
	cairo_set_source_rgba (cr, 0, 0, 0, 1);


	draw_hexagon_h(cr, x, 					y+a*2*math.sin(t), 	a)
	-- cairo_set_source_rgba (cr, 0.976, 0.941, 0.949, 0.09);
	cairo_set_source (cr, radpat);
	fill_hexagon_h(cr, x+0.05*a, 					y+a*2*math.sin(t), 	0.95*a)
	cairo_set_source_rgba (cr, 0, 0, 0, 1);


	draw_hexagon_h(cr, x+a*3, 				y+a*2*math.sin(t), 	a)
	-- cairo_set_source_rgba (cr, 0.976, 0.941, 0.949, 0.09);
	cairo_set_source (cr, radpat);
	fill_hexagon_h(cr, x+a*3.05, 				y+a*2*math.sin(t), 	0.95*a)
	cairo_set_source_rgba (cr, 0, 0, 0, 1);

end

function centre_to_corner(xc, yc, a)
	t = math.pi/3
	x, y = xc - a*(0.5 + math.cos(t)), yc
	return x, y
end
