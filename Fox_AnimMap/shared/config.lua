Config = {}

-- auto = detecta VORP/RSG automaticamente.
-- Tambem aceita: 'vorp', 'rsg' ou 'standalone'.
Config.Framework = 'auto'

Config.Command = {
    enabled = true,
    name = 'mapa'
}

Config.Item = {
    enabled = true,
    name = 'mapa',
    consume = false,
    closeInventory = true,

    -- No RSG o item pode ser adicionado ao Shared.Items automaticamente.
    rsg = {
        label = 'Mapa',
        weight = 100,
        image = 'mapa.png',
        unique = false,
        shouldClose = true,
        description = 'Um mapa para consultar a região.'
    }
}

-- Mantem a animacao automatica quando o jogador abre o mapa normalmente.
Config.AnimateNormalMapOpen = true

-- Ao usar comando/item, abre/fecha o UIApp nativo do mapa.
Config.ToggleMapWithCommandAndItem = true

Config.Map = {
    model = 's_twofoldmap01x_us',
    animDict = 'mech_inspection@two_fold_map@satchel',
    enterAnim = 'enter',
    exitAnim = 'exit_satchel',
    carryAnimDict = 'mech_carry_box',
    carryAnim = 'idle',
    boneName = 'SKEL_L_Finger12',
    spawnDelay = 2000,
    offset = { x = 0.2, y = 0.0, z = -0.15 },
    rotation = { x = 180.0, y = 190.0, z = 0.0 }
}

Config.Debug = false
