
local radToDeg = 180.0 / math.pi;
local degToRad = math.pi / 180.0;


---
---@param angle number
---@return number
local function NormalizeAngle(angle)
    local modAngle = angle % 360.0

    if modAngle < 0.0 then
        return modAngle + 360.0
    else
        return modAngle
    end
end

---commentary_started
---@param angles Vector
---@return Vector
local function NormalizeAngles(angles)
    angles.x = NormalizeAngle(angles.x)
    angles.y = NormalizeAngle(angles.y)
    angles.z = NormalizeAngle(angles.z)
    return angles
end

---commentary_started
---@param rotation UQuaternion
local function Internal_ToEulerRad(rotation)
    local sqw = rotation.w * rotation.w
    local sqx = rotation.x * rotation.x
    local sqy = rotation.y * rotation.y
    local sqz = rotation.z * rotation.z
    local unit = sqx + sqy + sqz + sqw -- if normalised is one, otherwise is correction factor
    local test = rotation.x * rotation.w - rotation.y * rotation.z
    local v = Vector()

    if test > 0.4995 * unit then -- singularity at north pole
        v.y = 2 * math.atan2(rotation.y, rotation.x)
        v.x = math.pi / 2
        v.z = 0
        return NormalizeAngles(v * radToDeg)
    end
    if test < -0.4995 * unit then -- singularity at south pole
        v.y = -2 * math.atan2(rotation.y, rotation.x)
        v.x = -math.pi / 2
        v.z = 0
        return NormalizeAngles(v * radToDeg)
    end
    local q = UQuaternion(rotation.w, rotation.z, rotation.x, rotation.y)
    v.y = math.atan2(2 * q.x * q.w + 2 * q.y * q.z, 1 - 2 * (q.z * q.z + q.w * q.w));     -- Yaw
    v.x = math.asin(2 * (q.x * q.z - q.w * q.y));                             -- Pitch
    v.z = math.atan2(2 * q.x * q.y + 2 * q.z * q.w, 1 - 2 * (q.y * q.y + q.z * q.z));      -- Roll
    return NormalizeAngles(v * radToDeg);
end

---commentary_started
---@param euler Vector
---@return UQuaternion
local function Internal_FromEulerRad(euler)
    ---@TODO double check these for source engine
    local yaw = euler.x
    local pitch = euler.y
    local roll = euler.z
    local rollOver2 = roll* 0.5
    local sinRollOver2 = math.sin(rollOver2)
    local cosRollOver2 = math.cos(rollOver2)
    local pitchOver2 = pitch * 0.5
    local sinPitchOver2 = math.sin(pitchOver2)
    local cosPitchOver2 = math.cos(pitchOver2)
    local yawOver2 = yaw * 0.5
    local sinYawOver2 = math.sin(yawOver2)
    local cosYawOver2 = math.cos(yawOver2)
    local result = UQuaternion()
    result.x = cosYawOver2 * cosPitchOver2 * cosRollOver2 + sinYawOver2 * sinPitchOver2 * sinRollOver2
    result.y = cosYawOver2 * cosPitchOver2 * sinRollOver2 - sinYawOver2 * sinPitchOver2 * cosRollOver2
    result.z = cosYawOver2 * sinPitchOver2 * cosRollOver2 + sinYawOver2 * cosPitchOver2 * sinRollOver2
    result.w = sinYawOver2 * cosPitchOver2 * cosRollOver2 - cosYawOver2 * sinPitchOver2 * sinRollOver2
    return result
end

---@class UQuaternion
---@field x number
---@field y number
---@field z number
---@field w number
---@field xyz Vector
---@field identity UQuaternion
---@operator call:UQuaternion
UQuaternion = {}

function IsUQuaternion(value)
    return type(value) == "table" and getmetatable(value) == UQuaternion
end

--Get
UQuaternion.__index = function (self, k)
    if k == 0 then return self.x
    elseif k == 1 then return self.y
    elseif k == 2 then return self.z
    elseif k == 3 then return self.w
    elseif k == "xyz" then
        return Vector(self.x, self.y, self.z)
    elseif k == "identity" then
        return UQuaternion(0, 0, 0, 1)
    elseif k == "eulerAngles" then
        return Internal_ToEulerRad(self) * radToDeg
    else
        return nil
    end
end

--Set
UQuaternion.__newindex = function (self, k, v)
    if k == 0 then self.x = v
    elseif k == 1 then self.y = v
    elseif k == 2 then self.z = v
    elseif k == 3 then self.w = v
    elseif k == "xyz" then
        self.x = v
        self.y = v
        self.z = v
    elseif k == "eulerAngles" then
        self:SetAs(Internal_FromEulerRad(v * degToRad))
    else
        rawset(self, k, v)
    end
end

UQuaternion.__eq = function(self, other)
    if not IsUQuaternion(other) then
        return false
    end
    ---@cast other UQuaternion
    return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
end

UQuaternion.__mul = function(lhs, rhs)
    if IsUQuaternion(rhs) then
        ---@cast rhs UQuaternion
        return UQuaternion(lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y, lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z, lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x, lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z)
    elseif IsVector(rhs) then
        local num = lhs.x * 2;
        local num2 = lhs.y * 2;
        local num3 = lhs.z * 2;
        local num4 = lhs.x * num;
        local num5 = lhs.y * num2;
        local num6 = lhs.z * num3;
        local num7 = lhs.x * num2;
        local num8 = lhs.x * num3;
        local num9 = lhs.y * num3;
        local num10 = lhs.w * num;
        local num11 = lhs.w * num2;
        local num12 = lhs.w * num3;
        local result = Vector();
        result.x = (1 - (num5 + num6)) * rhs.x + (num7 - num12) * rhs.y + (num8 + num11) * rhs.z;
        result.y = (num7 + num12) * rhs.x + (1 - (num4 + num6)) * rhs.y + (num9 - num10) * rhs.z;
        result.z = (num8 - num11) * rhs.x + (num9 + num10) * rhs.y + (1 - (num4 + num5)) * rhs.z;
        return result;
    end
end

function UQuaternion:Length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
end

function UQuaternion:LengthSquared()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function UQuaternion:Normalize()
    local scale = 1.0 / self:Length()
    self.xyz = self.xyz * scale
    self.w = self.w * scale
end

---Instantiate
---@return UQuaternion
UQuaternion.__call = function(t, x, y, z, w)
    if IsVector(x) and type(y) == "number" then
        w = y
        x, y, z = x:Unpack()
    end
    return setmetatable({
        x = x or 0,
        y = y or 0,
        z = z or 0,
        w = w or 1
    }, UQuaternion)
end

-- function Quaternion(x, y, z, w)
--     return setmetatable({
--         x = x, y = y, z = z, w = w
--     }, UQuaternion)
-- end

function UQuaternion:Set(x, y, z, w)
    self.x = x
    self.y = y
    self.z = z
    self.w = w
end

---custom function
function UQuaternion:SetAs(quat)
    self:Set(quat.x, quat.y, quat.z, quat.w)
end

function UQuaternion:Dot(quat)
    return self.x * quat.x + self.y * quat.y + self.z * quat.z + self.w * quat.w
end

---Creates a rotation which rotates /angle/ degrees around /axis/.
---@param angle number
---@param axis Vector
function UQuaternion.AngleAxis(angle, axis)
    if axis:LengthSquared() == 0.0 then
        return UQuaternion.identity
    end

    local result = UQuaternion.identity
    local radians = Deg2Rad(angle)
    radians = radians * 0.5
    axis = axis:Normalized()
    axis = axis * math.sin(radians)
    result.x = axis.x
    result.y = axis.y
    result.z = axis.z
    result.w = math.cos(radians)

    result:Normalize()

    return result
end


function UQuaternion:ToAngleAxis()
    if math.abs(self.w) > 1.0 then
        self:Normalize()
    end

    local angle = 2.0 * math.acos(self.w)
    local den = math.sqrt(1.0 - self.w * self.w)
    local axis
    if den > 0.0001 then
        axis = self.xyz / den
    else
        -- This occurs when the angle is zero.
        -- Not a problem: just set an arbitrary normalized axis.
        axis = Vector(1, 0, 0)
    end

    -- angle = angle * (180 / math.pi)
    angle = Rad2Deg(angle)

    return angle, axis
end

---Creates a rotation which rotates from /fromDirection/ to /toDirection/.
---@param fromDirection Vector
---@param toDirection Vector
function UQuaternion.FromToRotation(fromDirection, toDirection)
    return UQuaternion.RotateTowards(UQuaternion.LookRotation(fromDirection), UQuaternion.LookRotation(toDirection), math.huge)
end

---Creates a rotation which rotates from /fromDirection/ to /toDirection/.
---@param fromDirection Vector
---@param toDirection Vector
function UQuaternion:SetFromToRotation(fromDirection, toDirection)
    self:SetAs(UQuaternion.FromToRotation(fromDirection, toDirection))
end

---Creates a rotation with the specified /forward/ and /upwards/ directions.
---@param forward Vector
---@param up? Vector
function UQuaternion.LookRotation(forward, up)
    up = up or Vector(0, 0, 1)

    forward = forward:Normalized()
    local right = up:Cross(forward):Normalized()
    up = forward:Cross(right)
    local m00 = right.x
    local m01 = right.y
    local m02 = right.z
    local m10 = up.x
    local m11 = up.y
    local m12 = up.z
    local m20 = forward.x
    local m21 = forward.y
    local m22 = forward.z


    local num8 = (m00 + m11) + m22
    local quaternion = UQuaternion()
    if num8 > 0 then
        local num = math.sqrt(num8 + 1)
        quaternion.w = num * 0.5
        num = 0.5 / num
        quaternion.x = (m12 - m21) * num
        quaternion.y = (m20 - m02) * num
        quaternion.z = (m01 - m10) * num
        return quaternion
    end
    if m00 >= m11 and m00 >= m22 then
        local num7 = math.sqrt(((1 + m00) - m11) - m22)
        local num4 = 0.5 / num7
        quaternion.x = 0.5 * num7
        quaternion.y = (m01 + m10) * num4
        quaternion.z = (m02 + m20) * num4
        quaternion.w = (m12 - m21) * num4
        return quaternion
    end
    if m11 > m22 then
        local num6 = math.sqrt(((1 + m11) - m00) - m22)
        local num3 = 0.5 / num6
        quaternion.x = (m10 + m01) * num3
        quaternion.y = 0.5 * num6
        quaternion.z = (m21 + m12) * num3
        quaternion.w = (m20 - m02) * num3
        return quaternion
    end
    local num5 = math.sqrt(((1 + m22) - m00) - m11)
    local num2 = 0.5 / num5
    quaternion.x = (m20 + m02) * num2
    quaternion.y = (m21 + m12) * num2
    quaternion.z = 0.5 * num5
    quaternion.w = (m01 - m10) * num2
    return quaternion
end

---Creates a rotation with the specified /forward/ and /upwards/ directions.
---@param view Vector
---@param up? Vector
function UQuaternion:SetLookRotation(view, up)
    up = up or Vector(0, 0, 1)
    self:SetAs(UQuaternion.LookRotation(view, up))
end

---Spherically interpolates between /a/ and /b/ by t. The parameter /t/ is clamped to the range [0, 1].
---@param a UQuaternion
---@param b UQuaternion
---@param t number
---@return UQuaternion
function UQuaternion.Slerp(a, b, t)
    if t > 1 then t = 1 end
    if t < 0 then t = 0 end
    return UQuaternion.SlerpUnclamped(a, b, t)
end

---Spherically interpolates between /a/ and /b/ by t. The parameter /t/ is not clamped.
---@param a UQuaternion
---@param b UQuaternion
---@param t number
---@return UQuaternion
function UQuaternion.SlerpUnclamped(a, b, t)
    if a:LengthSquared() == 0.0 then
        if b:LengthSquared() == 0.0 then
            return UQuaternion.identity
        end
        return b
    elseif b:LengthSquared() == 0.0 then
        return a
    end

    local cosHalfAngle = a.w * b.w + a.xyz:Dot(b.xyz)

    if cosHalfAngle >= 1.0 or cosHalfAngle <= -1.0 then
        return a
    elseif cosHalfAngle < 0.0 then
        -- wise to modify parameter object?
        -- https://gist.github.com/HelloKitty/91b7af87aac6796c3da9#file-quaternion-cs-L445
        b.xyz = -b.xyz
        b.w = -b.w
        cosHalfAngle = -cosHalfAngle
    end

    local blendA
    local blendB
    if cosHalfAngle < 0.99 then
        -- do proper slerp for big angles
        local halfAngle = math.acos(cosHalfAngle)
        local sinHalfAngle = math.sin(halfAngle)
        local oneOverSinHalfAngle = 1.0 / sinHalfAngle
        blendA = math.sin(halfAngle * (1.0 - t)) * oneOverSinHalfAngle
        blendB = math.sin(halfAngle * t) * oneOverSinHalfAngle
    else
        blendA = 1.0 - t
        blendB = t
    end

    local result = UQuaternion(blendA * a.xyz + blendB * b.xyz, blendA * a.w + blendB * b.w)
    if result:LengthSquared() > 0.0 then
        result:Normalize()
        return result
    else
        return UQuaternion.identity
    end
end

function UQuaternion.Lerp(a, b, t)
    if t > 1 then t = 1 end
    if t < 0 then t = 0 end
    return UQuaternion.Slerp(a, b, t) -- TODO: use lerp not slerp, "Because quaternion works in 4D. Rotation in 4D are linear" ???
end

function UQuaternion.LerpUnclamped(a, b, t)
    return UQuaternion.Slerp(a, b, t)
end

---Rotates a rotation /from/ towards /to/.
---@param from UQuaternion
---@param to UQuaternion
---@param maxDegreesDelta number
---@return UQuaternion
function UQuaternion.RotateTowards(from, to, maxDegreesDelta)
    local num = UQuaternion.Angle(from, to)
    if num == 0 then
        return to
    end
    local t = math.min(1, maxDegreesDelta / num)
    return UQuaternion.SlerpUnclamped(from, to, t)
end

---Returns the Inverse of /rotation/.
---@param rotation UQuaternion
function UQuaternion.Inverse(rotation)
    local lengthSq = rotation:LengthSquared()
    if lengthSq ~= 0.0 then
        local i = 1.0 / lengthSq
        return UQuaternion(rotation.xyz * -i, rotation.w * i)
    end
    return rotation
end

---Returns a nicely formatted string of the Quaternion
---@param self UQuaternion
---@return string
function UQuaternion.__tostring(self)
    return string.format("(%.1f, %.1f, %.1f, %.1f)", self.x, self.y, self.z, self.w)
end

---Returns the angle in degrees between two rotations /a/ and /b/.
---@param a UQuaternion
---@param b UQuaternion
---@return number
function UQuaternion.Angle(a, b)
    local f = a:Dot(b)
    return Rad2Deg(math.acos(math.min(math.abs(f), 1)) * 2)
end

---Returns a rotation that rotates z degrees around the z axis, x degrees around the x axis, and y degrees around the y axis (in that order).
---@param x number
---@param y number
---@param z number
---@return UQuaternion
---@overload fun(euler: Vector): UQuaternion
function UQuaternion.Euler(x, y, z)
    local euler
    if IsVector(x) then
        euler = x
    else
        euler = Vector(x, y, z)
    end

    return Internal_FromEulerRad(euler)
end



local t = UQuaternion(1, 2)