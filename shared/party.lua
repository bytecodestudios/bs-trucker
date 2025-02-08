Config = Config or {}

Config.Debug = false

Config.Party = {
	minSize = 1,
	maxSize = 2,
	maxPlayerLimit = 12,
	jobName = 'Trucker',
	jobIcon = 'fas fa-truck', -- icon to show when this job is assigned
	jobType = 'legal',
	jobBlip = {
		name = 'Post OP',
		coords = vector3(-426.82, -2801.27, 6.0),
		sprite = 478,
		color = 21
	},
	jobPeds = {
		['deliverystart'] = {
			model = `s_m_m_ups_01`,
			coords = vector4(-425.44, -2786.74, 6.0, 317.92),
			type = 'male',
			freeze = true,
			blockevents = true,
			invincible = true,
		},
		['deliveryrental'] = {
			model = `s_m_m_ups_01`,
			coords = vector4(-432.8, -2789.82, 6.0, 52.3),
			type = 'male',
			freeze = true,
			blockevents = true,
			invincible = true,
		},
		['deliverytrucker'] = {
			model = `s_m_m_postal_01`,
			coords = vector4(1197.21, -3253.58, 7.1, 88.0),
			type = 'male',
			freeze = true,
			blockevents = true,
			invincible = true,
		},
		['deliverytrucker2'] = {
			model = `s_m_m_postal_01`,
			coords = vector4(348.07, 3406.18, 36.44, 22.94),
			type = 'male',
			freeze = true,
			blockevents = true,
			invincible = true,
		},
		['deliverytrucker3'] = {
			model = `s_m_m_postal_01`,
			coords = vector4(-244.46, 6066.26, 32.34, 142.43),
			type = 'male',
			freeze = true,
			blockevents = true,
			invincible = true,
		},
	},
	jobZone = {
		{ coords = vec3(-425.44, -2786.74, 6.0), size = vec3(1.35, 1.0, 2.25), rotation = 226.5 },
	},
	jobVehZone = {
		{ coords = vec3(-432.8, -2789.82, 6.0), size = vec3(1.35, 1.0, 2.25), rotation = 226.5 },
	},
	jobSpawns = {
		vector4(-445.83, -2790.06, 6.07, 44.5),
		vector4(-450.44, -2794.87, 6.07, 44.71),
		vector4(-454.35, -2799.68, 6.07, 44.42),
		vector4(-459.65, -2803.37, 6.07, 46.1),
		vector4(-463.94, -2807.88, 6.07, 44.73),
		vector4(-468.73, -2812.61, 6.07, 44.53),
		vector4(-477.26, -2821.75, 6.07, 46.75),
		vector4(-481.57, -2826.29, 6.07, 45.88),
		vector4(-485.14, -2831.95, 6.07, 45.67),
		vector4(-494.8, -2840.16, 6.07, 44.69),
		vector4(-499.81, -2844.29, 6.07, 45.28),
		vector4(-503.81, -2849.36, 6.07, 45.69),
		vector4(-508.75, -2853.26, 6.07, 45.79),
		vector4(-512.81, -2858.25, 6.07, 45.95),
		vector4(-521.59, -2867.16, 6.07, 45.16)
	},
	jobVehicle = {
		-- jobName = {model = 'MODEL_HASH_NAME', price = 0},
		['trucker'] = {model = 'phantom3', price = 350},
	}
}