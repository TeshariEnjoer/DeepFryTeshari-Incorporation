#define LASER_SWEEP_PI 3.1415926535

/proc/get_farthest_turf_at_angle(turf/start, angle_deg, max_dist = 60)
	if(!start)
		return null
	var/rad = angle_deg * LASER_SWEEP_PI / 180
	var/dx = cos(rad)
	var/dy = sin(rad)
	var/turf/last_clear = start

	for(var/i in 1 to max_dist)
		var/next_x = start.x + (dx * i)
		var/next_y = start.y + (dy * i)
		var/turf/next = locate(ceil(next_x), ceil(next_y), start.z)
		if(!next || next.density)
			return last_clear
		last_clear = next
	return last_clear

/proc/get_ray_path(turf/start, angle_deg, max_dist = 60)
	if(!start)
		return list()
	var/rad = angle_deg * LASER_SWEEP_PI / 180
	var/dx = cos(rad)
	var/dy = sin(rad)
	var/list/path = list()


	for(var/i in 1 to max_dist)
		var/next_x = start.x + dx * i
		var/next_y = start.y + dy * i
		var/turf/next = locate(ceil(next_x), ceil(next_y), start.z)
		if(!next || next.density)
			break
		path += next
	return path

/proc/get_angle_between(turf/t1, turf/t2)
	if(!t1 || !t2 || t1.z != t2.z)
		return 0

	var/dx = t2.x - t1.x
	var/dy = t2.y - t1.y


	var/angle_rad = ATAN2(dy, dx)

	var/angle_deg = angle_rad * 180 / PI
	if(angle_deg < 0)
		angle_deg += 360

	return round(angle_deg)
