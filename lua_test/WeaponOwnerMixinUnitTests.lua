// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// WeaponOwnerMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/WeaponOwnerMixin.lua")
Script.Load("lua/Entity.lua")
module( "WeaponOwnerMixinUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'WeaponOwnerTestClass' (Entity)

function WeaponOwnerTestClass:Drop()
    assert(false)
end

function WeaponOwnerTestClass:AddChild(child)
    table.insert(self.children, child)
end

function WeaponOwnerTestClass:RemoveChild(child)
    table.removevalue(self.children, child)
end

function WeaponOwnerTestClass:GetNumChildren()
    return #self.children
end

function WeaponOwnerTestClass:GetChildAtIndex(index)
    return self.children[index + 1]
end

WeaponOwnerTestClass.networkVars = { }
PrepareClassForMixin(WeaponOwnerTestClass, WeaponOwnerMixin)

local function CreateMockWeapon(weight, hudSlot, mapName)

    local mockWeapon = CreateMockEntity()
    
    SetMockType(mockWeapon, "Weapon")
    mockWeapon:AddFunction("GetWeight"):SetReturnValues({ weight })
    mockWeapon:AddFunction("GetHUDSlot"):SetReturnValues({ hudSlot })
    mockWeapon:AddFunction("SetParent"):AddCall(
                                                function(self, parent)
                                                    if self.parent then
                                                        self.parent:RemoveChild(self)
                                                    end
                                                    self.parent = parent
                                                    if self.parent then self.parent:AddChild(self) end
                                                end)
    mockWeapon:RemoveFunction("GetParent")
    mockWeapon:AddFunction("GetParent"):AddCall(function(self) return self.parent end)
    mockWeapon:AddFunction("SetOrigin"):AddCall(function(self, origin) self.origin = origin end)
    mockWeapon:AddFunction("GetMapName"):SetReturnValues({ mapName })
    mockWeapon:AddFunction("OnDraw")
    mockWeapon:AddFunction("OnHolster")
    mockWeapon:AddFunction("SetIsVisible")
    
    return mockWeapon

end

local testWeaponOwner
// Tests begin.
function setup()

    testWeaponOwner = WeaponOwnerTestClass()
    testWeaponOwner.children = { }
    InitMixin(testWeaponOwner, WeaponOwnerMixin, { kStowedWeaponWeightScalar = 0.7 })

end

function teardown()
end

function TestWeaponsWeight()

    assert_equal(0, testWeaponOwner:GetWeaponsWeight())
    
    local mockWeapon = CreateMockWeapon(0.05, 1, "rifle")
    testWeaponOwner:AddWeapon(mockWeapon, false)
    
    assert_float_equal(0.035, testWeaponOwner:GetWeaponsWeight())
    
    testWeaponOwner:SetActiveWeapon(mockWeapon:GetMapName())
    
    assert_float_equal(0.05, testWeaponOwner:GetWeaponsWeight())
    
    local mockWeapon2 = CreateMockWeapon(0.1, 2, "shotgun")
    testWeaponOwner:AddWeapon(mockWeapon2, true)
    
    assert_float_equal(0.135, testWeaponOwner:GetWeaponsWeight())
    
    testWeaponOwner:RemoveWeapon(mockWeapon)
    
    assert_float_equal(0.1, testWeaponOwner:GetWeaponsWeight())

end