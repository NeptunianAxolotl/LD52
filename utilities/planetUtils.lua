
local api = {}

local function ClosestToWithDistSq(data, maxDistSq, px, py, filterFunc)
	if data.isDead or data.body:isDestroyed() then
		return false
	end
	if filterFunc and not filterFunc(data) then
		return false
	end
	local bx, by = data.body:getWorldCenter()
	local distSq = util.DistSqWithWrap(bx, by, px, py, Global.WORLD_WIDTH, Global.WORLD_HEIGHT)
	if maxDistSq and distSq > maxDistSq then
		return false
	end
	return distSq
end

function api.ApplyForceTowards(body, pos, forceSize)
	local bx, by = body:getWorldCenter()
	local force = util.Mult(forceSize, util.UnitTowardsWithWrap({bx, by}, pos, Global.WORLD_WIDTH, Global.WORLD_HEIGHT))
	body:applyForce(force[1], force[2])
end

function api.GetClosestAsteroid(bx, by, maxDist)
	local other = IterableMap.GetMinimum(EnemyHandler.GetAsteroids(), ClosestToWithDistSq, maxDist and maxDist*maxDist, bx, by)
	if not other then
		return
	end
	return other
end

function api.GetClosestBullet(bx, by, maxDist)
	local other = IterableMap.GetMinimum(EnemyHandler.GetBullets(), ClosestToWithDistSq, maxDist and maxDist*maxDist, bx, by)
	if not other then
		return
	end
	return other
end

function api.GetClosestPlanet(bx, by, maxDist, filterFunc)
	local other = IterableMap.GetMinimum(TerrainHandler.GetPlanets(), ClosestToWithDistSq, maxDist and maxDist*maxDist, bx, by, filterFunc)
	if not other then
		return
	end
	return other
end

function api.ForceTowardsClosest(body, objType, forceSize, maxDist, doFalloff, angle, filterFunc)
	local bx, by = body:getWorldCenter()
	local ox, oy, other = false, false, false
	if objType == "asteroid" then
		other = api.GetClosestAsteroid(bx, by, maxDist)
		if not other then
			return false
		end
		ox, oy = other.body:getWorldCenter()
	elseif objType == "planet" then
		other = api.GetClosestPlanet(bx, by, maxDist, filterFunc)
		if not other then
			return false
		end
		ox, oy = other.body:getWorldCenter()
	elseif objType == "bullet" then
		other = api.GetClosestBullet(bx, by, maxDist)
		if not other then
			return false
		end
		ox, oy = other.body:getWorldCenter()
	elseif objType == "player" then
		other = PlayerHandler.GetPlayerShip()
		if not other then
			return false
		end
		ox, oy = other.body:getWorldCenter()
	elseif objType == "sun" then
		ox, oy = TerrainHandler.GetSunX(), TerrainHandler.GetSunY()
	end
	
	if not ox then
		return false
	end

	if maxDist then
		local distSq = util.DistSq(ox, oy, bx, by)
		if distSq > maxDist*maxDist then
			return false
		end
	end
	
	local towards, dist = util.UnitTowardsWithWrap({bx, by}, {ox, oy}, Global.WORLD_WIDTH, Global.WORLD_HEIGHT)
	if doFalloff then
		forceSize = forceSize * (1 - dist / maxDist)
	end
	local forceVec = util.Mult(forceSize, towards)
	if angle then
		forceVec = util.RotateVector(forceVec, angle)
	end
	body:applyForce(forceVec[1], forceVec[2])
	return forceVec, other
end

function api.RepelFunc(key, other, index, dt, repelPos, planetKey, planetRadius, repelDist, repelForce)
	if other.def.parentKey == planetKey then
		return
	end
	repelDist = repelDist or Global.REPEL_DIST
	repelForce = repelForce or Global.REPEL_MAX_FORCE
	local bx, by = other.body:getWorldCenter()
	local dist = util.Dist(bx, by, repelPos[1], repelPos[2]) - planetRadius
	if dist > repelDist then
		return
	end
	api.ApplyForceTowards(other.body, repelPos, -1 * repelForce * (1 - dist / repelDist))
end

function api.ShootAtBody(targetBody, myBody, projType, projSpeed, spawnRadius, myKey)
	local ax, ay = targetBody:getWorldCenter()
	local aVx, aVy = targetBody:getLinearVelocity()
	
	local mx, my = myBody:getWorldCenter()
	local mVx, mVy = myBody:getLinearVelocity()

	-- Relativity
	aVx, aVy = aVx - mVx, aVy - mVy

	-- Find a predicted travel time that matches predicted velocity
	local bestTravel = 0.1
	local bestTravelDelta = 100
	local gravityAccel = TerrainHandler.GetLocalGravityAccel(ax, ay)
	for travelTest = 0.1, 1.6, 0.1 do
		local px = ax + travelTest * aVx + 0.5 * travelTest * travelTest * gravityAccel[1]
		local py = ay + travelTest * aVy + 0.5 * travelTest * travelTest * gravityAccel[2]
		local travelTime = (util.Dist(mx, my, px, py) - spawnRadius) / projSpeed
		if math.abs(travelTime - travelTest) < bestTravelDelta then
			bestTravel = travelTime
			bestTravelDelta = math.abs(travelTime - travelTest)
			if bestTravelDelta < 0.08 then
				break
			end
		end
	end
	local travelTime = bestTravel
	local px, py = ax + travelTime * aVx, ay + travelTime * aVy

	-- Shoot at predicted spot
	local toPrediction = util.Unit({px - mx, py - my})
	local bulletData = {
		pos = util.Add({mx, my}, util.Mult(spawnRadius, toPrediction)),
		velocity = util.Add({mVx, mVy}, util.Mult(projSpeed, toPrediction)),
		typeName = projType,
		target = targetBody,
		parentKey = myKey,
	}
	EnemyHandler.AddBullet(bulletData)
	return true
end

return api
