// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockTechConstants.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Server script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("MockMagic.lua")

function MockTechType()

    // Mock tech type and tech ids
    local mockTechType = MockMagic.CreateGlobalMock("kTechType")
    mockTechType['Invalid'] = 1
    mockTechType['Order'] = 2
    mockTechType['Research'] = 3
    mockTechType['Upgrade'] = 4
    mockTechType['Action'] = 5
    mockTechType['Buy'] = 6
    mockTechType['Build'] = 7
    mockTechType['EnergyBuild'] = 8
    mockTechType['Manufacture'] = 9
    mockTechType['Activation'] = 10
    mockTechType['Menu'] = 11
    mockTechType['EnergyManufacture'] = 12
    mockTechType['PlasmaManufacture'] = 13
    mockTechType['Special'] = 14

    return mockTechType
    
end
    
function MockTechId()

    local mockTechId = MockMagic.CreateGlobalMock("kTechId")
    mockTechId['None'] = 1
    mockTechId['Build'] = 2
    mockTechId['Armory'] = 3
    mockTechId['ArmsLab'] = 4
    mockTechId['Weapons1'] = 5
    mockTechId['Weapons2'] = 6
    mockTechId['Weapons3'] = 7
    mockTechId['Armor1'] = 8
    mockTechId['Armor2'] = 9
    mockTechId['Armor3'] = 10
    mockTechId['HighTech'] = 11
    mockTechId['Max'] = 12
   
    return mockTechId
 
end