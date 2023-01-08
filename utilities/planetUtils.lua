
local api = {}

function api.ApplyForceTowards(body, pos, forceSize)
	local bx, by = body:getWorldCenter()
	local force = util.Mult(forceSize, util.Unit({pos[1] - bx, pos[2] - by}))
	body:applyForce(force[1], force[2])
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
