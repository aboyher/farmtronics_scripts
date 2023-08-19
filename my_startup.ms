
manhattanDistance = function(a,b)
    return abs(a[0] - b[0]) + abs(a[1] - b[1])
end function

rotate = function(current_position, next_position)
    if current_position[0] > next_position[0] then
        need_to_face = 3
    else if current_position[0] < next_position[0] then
        need_to_face = 1
    else if current_position[1] > next_position[1] then
        need_to_face = 0
    else if current_position[1] < next_position[1] then
        need_to_face = 2
    else
        // print("somethign is wrong")
        return
    end if
    while need_to_face != me.facing
        if me.facing == need_to_face + 1 then
            print("turning left")
            me.left
        else if me.facing == need_to_face - 1 then
            print("turning right")
            me.right
        else
            print("turning left")
            me.left
        end if
    end while
end function


get_farm_passable = function
    passable_matrix = [1]*(farm.width)
    for x in range(0, farm.width-1)
        row_passable = [1]*(farm.height)
        for y in range(0, farm.height-1)
            t = farm.tile(x,y)
            if not t then continue
            row_passable[y] = t.passable
        end for
        passable_matrix[x] = row_passable
    end for
    return passable_matrix
end function


reverse_list = function(l)
    rlist = []
    for item in l
        rlist = [item] + rlist
    end for
    return rlist
end function

Node = {"parent": null, "position": null}
Node.g=0
Node.h=0
Node.f=0

Node.__eq__ = function(other)
    return self.position == other.position
end function

Node.__hash__ = function(self)
	return hash(self.position)
end function


astar = function(farm_map, start, target)

    start_node = new Node
    start_node.position = start
    end_node = new Node
    end_node.position = target

    open_list =  []
    closed_list = []

    open_list.push(start_node)
	checked_tiles = 0
    while open_list.len > 0
        if checked_tiles > 3000 then
			print("no path found in 3000 checked")
			return false
		end if
        current_node = open_list[0]
        current_index = 0
        for index in range(0, open_list.len - 1)
            // print("b")
            // print(index)
            item = open_list[index]
            if item.f < current_node.f then
                // print("if item.f < current_node.f then")
                current_node = item
                current_index = index
            end if
        end for
        // print("c")
        open_list.remove(current_index)
		if not itemInList(current_node, closed_list) then
        	closed_list.push(current_node)
		end if


        if current_node.position == end_node.position then
            path = []
            current = current_node
            while current
                path.push(current.position)
                current = current.parent
            end while
            return reverse_list(path)[1:]
        end if

        children = []
        for new_position in [[0, -1], [0, 1], [-1, 0], [1, 0]]
            // print("d")
            node_position = [current_node.position[0] + new_position[0], current_node.position[1] + new_position[1]]
            // print("e")
            if node_position[0] > (farm_map.len - 1) or node_position[0] < 0 or node_position[1] > (farm_map[farm_map.len-1].len - 1) or node_position[1] < 0 then
                continue
            end if
            // print("f")
            if farm_map[node_position[0]][node_position[1]] != 1 then
                continue
            end if
            new_node = new Node
            new_node.parent = current_node
            new_node.position = node_position
            children.push(new_node)

        end for
        // print(children.len)
        if children.len > 8 then return

        for child in children

			if itemInList(child, closed_list) then continue
			checked_tiles = checked_tiles + 1
            child.g = current_node.g + 1
            // print("g")
            child.h = ((child.position[0] - end_node.position[0]) ^ 2) + ((child.position[1] - end_node.position[1]) ^ 2)
            child.f = child.g + child.h
            // print(str(child.g) + " " + str(child.h) + " " + str(child.f))
            // return

            for open_node in open_list
                if child == open_node and child.g > open_node.g then
                    continue
                end if
            end for

            open_list.push(child)
        end for
    end while
	return false

end function

navigate = function(path)
    target = path[-1]
    while my_position != target
        print(path)
        next_position = path.pull()
        print(str(my_position) + " going to " + str(next_position))
        rotate(my_position, next_position)
        print("moving forward")
        me.forward
    end while
end function


my_position = function
    return [me.position.x, me.position.y]
end function

goTo = function(target)
    farm_map = get_farm_passable()
    if not farm_map[target[0]][target[1]] then
        print("Position not accessible")
        return
    end if
    path = astar(farm_map, my_position, target)
	if not path then
		print("No viable path")
		return
	end if
    navigate(path)
    if my_position == target then print("Arrived") else print("Something went wrong with navigation")
end function


itemInList = function(item, arr)
	for el in arr
		if el.position == item.position then
			return true
		end if
	end for
	return false
end function

testVar = 0

findAllWater = function
	water_tiles = []
	for x in range(0, farm.width-1)
		for y in range(0, farm.height-1)
			t = farm.tile(x,y)
			if not t then continue
			if not t.name == "Water" then continue
			water_tiles.push([x,y])
		end for
	end for
	return water_tiles
end function

findNearestWater = function
	min_dist = 1000000
	shortest_path = []
	maze = get_farm_passable()
	for x in range(0, farm.width-1)
		for y in range(0, farm.height-1)
			t = farm.tile(x,y)
			if not t then continue
			if not t.name == "Water" then continue
			path = astar(maze, my_position, [x,y])
			if not path then continue
			if path.len < min_dist then
				shortest_path = path
				min_dist = path.len
			end if
		end for
	end for
	print(shortest_path)
end function

findAllCrops = function
	crops = []
	for x in range(0, farm.width-1)
		for y in range(0, farm.height-1)
			t = farm.tile(x,y)
			if not t then continue
			if t.type != "HoeDirt" then continue
			crop = t
			crop.position = [x, y]
			crops.push(crop)
		end for
	end for
	return crops
end function

waterCrops = function
	maze = get_farm_passable()
	if me.isWaterEmpty then me.fillWater
	crops = findAllCrops()
	while crops.len > 0
		closest_index = findClosestCrop(crops, maze)
		crop = crops[closest_index]
		crops.remove(closest_index)

	// for crop in crops
		if not crop.dry then continue
		if not crop.crop then continue
		target = crop.position
		print("target: " + str(target))
		if my_position == crop.position then
			print("moving to empty space")
			while not me.ahead.passable
				me.left
			end while
			me.forward
		end if
		print("getting path to target")
		path = astar(maze, my_position, target)
		// print(path)
		if path and path.len > 1 then
			print("navigating")
			navigate(path[:-1])
		end if
		print("rotating")
		rotate(my_position, target)
		print("watering")
		me.water
		if me.isWaterEmpty then me.fillWater
	end while
	world.chat("Crops Watered")
end function

me.water = function
    me.select "Watering Can"
    me.useTool
    wait
end function


me.isWaterEmpty = function
	for i in range(0, me.inventory.len - 1)
		inv = me.inventory[i]
		if not inv then continue
		if not inv.name == "Watering Can" then continue
		if inv.waterLeft > 0 then
			return false
		else
			return true
		end if
	end for
end function


me.fillWater = function
	water_spot = [46,28]
	goTo(water_spot)
	rotate(my_position, [46, 29])
	me.water
end function

findClosestCrop = function(crops, maze)
	min_dist = 1000000
	closest_index = null
	for i in range(0, crops.len-1)
		crop = crops[i]
		target = crop.position
		dist = sqrt((target[0] - my_position[0])^2 + (target[1] - my_position[1])^2)
		if dist < min_dist then
			closest_index = i
			min_dist = dist
		end if
	end for
	print(closest_index)
	return closest_index
end function

