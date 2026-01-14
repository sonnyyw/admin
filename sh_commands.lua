-- =====================================================
-- J0 ADMIN MENU - SHARED COMMAND DEFINITIONS (FIXED)
-- =====================================================

Config = Config or {}
Config.CommandList = Config.CommandList or {}

Config.CommandList = {
    {
        Id = 'player',
        Name = 'Player',
        Items = {
            {
                Id = 'changeModel',
                Name = 'Change Model',
                UseKVPGroups = true,
                Groups = {'all'},
                Event = 'Admin:Change:Model',
                Collapse = true,
                Options = {
                    { Id = 'player', Name = 'Player', Type = 'input-choice', PlayerList = true },
                    { Id = 'model', Name = 'Model', Type = 'input-choice', ChoicesSource = 'models' },
                },
            },
            {
                Id = 'setJob',
                Name = 'Set Job',
                UseKVPGroups = true,
                Groups = {'admin'},
                Event = 'Admin:Set:Job',
                Collapse = true,
                Options = {
                    { Id = 'player', Name = 'Player', Type = 'input-choice', PlayerList = true },
                    { Id = 'job', Name = 'Job', Type = 'input-choice', ChoicesSource = 'jobs' },
                    { Id = 'grade', Name = 'Grade', Type = 'number', Default = 0 },
                },
            },
            {
                Id = 'giveMoney',
                Name = 'Give Money',
                UseKVPGroups = true,
                Groups = {'admin'},
                Event = 'Admin:Give:Money',
                Collapse = true,
                Options = {
                    { Id = 'player', Name = 'Player', Type = 'input-choice', PlayerList = true },
                    { Id = 'type', Name = 'Type', Type = 'input-choice', ChoicesSource = 'money' },
                    { Id = 'amount', Name = 'Amount', Type = 'number' },
                },
            },
        },
    },
    {
        Id = 'vehicle',
        Name = 'Vehicle',
        Items = {
            {
                Id = 'spawnVehicle',
                Name = 'Spawn Vehicle',
                UseKVPGroups = true,
                Groups = {'admin'},
                Event = 'Admin:Vehicle:Spawn',
                Collapse = true,
                Options = {
                    { Id = 'model', Name = 'Vehicle', Type = 'input-choice', ChoicesSource = 'vehicles' },
                },
            },
        },
    },
    {
        Id = 'world',
        Name = 'World',
        Items = {
            {
                Id = 'setWeather',
                Name = 'Set Weather',
                UseKVPGroups = true,
                Groups = {'admin'},
                Event = 'Admin:World:Weather',
                Collapse = true,
                Options = {
                    { Id = 'weather', Name = 'Weather', Type = 'input-choice', ChoicesSource = 'weather' },
                },
            },
        },
    },
}
