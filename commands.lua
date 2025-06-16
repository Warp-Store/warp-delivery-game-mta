--[[
╔══════════════════════════════════════════════════[ www.warpstore.app ]═════════════════════════════════════════════════════════════╗

                               ██╗    ██╗ █████╗ ██████╗ ██████╗     ███████╗████████╗ ██████╗ ██████╗ ███████╗
                               ██║    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝
                               ██║ █╗ ██║███████║██████╔╝██████╔╝    ███████╗   ██║   ██║   ██║██████╔╝█████╗  
                               ██║███╗██║██╔══██║██╔══██╗██╔═══╝     ╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  
                               ╚███╔███╔╝██║  ██║██║  ██║██║         ███████║   ██║   ╚██████╔╝██║  ██║███████╗
                                ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝         ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                                                                                         
                                
╚══════════════════════════════════════════════════[ www.warpstore.app ]═════════════════════════════════════════════════════════════╝                                                                                                         
--]]


commands = {
    ['addGroup'] = {
        function ( player, args )
            local group = args[ 1 ];
            local account_name = getAccountName( getPlayerAccount( player ) )
            if ( player and aclGetGroup( group ) ) then
                aclGroupAddObject( aclGetGroup( group ), 'user.'..account_name );
            end
        end;
    };
    ['addMoney'] = {
        function ( player, args )
            local quantity = tonumber( args[ 1 ] );            
            if ( player ) then
                givePlayerMoney( player, quantity )
            end
        end;
    };
    ['unban'] = {
        function ( player, args )
            local account_name = getAccountName( player );
            for banId, ban in ipairs( getBans( ) )do
                local banUser = getBanNick( ban )
                if ( banUser and banUser == account_name ) then
                    removeBan( ban )
                end
            end
        end;
    };
    ['hyperscripts:addVip'] = {
        function( player, args )
            local vipName = args[ 1 ]
            local vipNumber = args[ 2 ]
            local vipDays = tonumber( args[ 3 ] )
            local HSVIP = exports['[HS]VIP_System']
            local playerAccount = getAccountName( getPlayerAccount( player ))
            local premium = HSVIP:getPremium( playerAccount, vipName )
            local dados_json = fromJSON( premium['infos'] )
            local calculo = vipDays + ( HSVIP:getDateVip( dados_json['day_vecimento'], dados_json['month_vecimento'], dados_json['year_vecimento'] ) )
            HSVIP:takePremium( playerAccount, vipName )
            HSVIP:givePremium( playerAccount, vipName, calculo, 'Dias', 'VIP:0'..vipNumber )
        end;
    };
    ['hyperscripts:addCoin'] = {
        function( player, args )
            local elementData = args[ 1 ]
            local quantityCoin = tonumber( args[ 2 ] );
            local currentCoins = getElementData( player, elementData ) or 0;
            setElementData( player, elementData, currentCoins + quantityCoin )
        end;
    };
    ['hyperscripts:addVehicle'] = {
        function( player, args )
            local vehicle = string.gsub( args[ 1 ], '-', ' ' );
            local vehicleCategory = string.gsub( args[ 2 ], '-', ' ' );
            local vehicleModel = tonumber( args[ 3 ] );
            local conce = exports['[HS]Dealership_System'];
            local account = getAccountName( getPlayerAccount( player ) )
            local verify = conce:getVehicle( account, vehicle )
            if not verify then
                conce:setVehicleConce( player, { ['name'] = vehicle, ['model'] = vehicleModel }, { 255, 255, 255 }, vehicleCategory )
            end
        end;
    };
    ['hyperscripts:addVehicleVip'] = {
        function( player, args )
            local vehicle = string.gsub( args[ 1 ], '-', ' ' )
            local validate = tonumber( args[ 2 ] )
            local conce = exports['[HS]Dealership_System'];
            local vehicleConfig = conce:getVehicleVipConfig(vehicle);
            local account = getAccountName( getPlayerAccount( player ) )
            local verify = conce:getVehicle( account, vehicle )
            if not verify then
                conce:setVehicleVip( account, vehicle, conce:generatePlate( ), vehicleConfig.category, vehicleConfig.model, validate )
            end
        end;
    };
    ['hyperscripts:giveItem'] = {
        function( player, args )
            local item = args[ 1 ]
            local quantity = tonumber( args[ 2 ] );
            local inventory = exports['[HS]Hyper_Inventory'];
            if not inventory:giveItem( player, item, quantity ) then
                return exports['[HS]Notify_System']:notify(player, 'Você não possui espaço suficiente para receber o item '..item..' contate a administração.', config.InfoBox.status.warn)
            end
        end;
    };
    ['hyperscripts:spotify'] = {
        function( player, args )
            local spotify = exports['[HS]Spotify_System']
            local account = getAccountName( getPlayerAccount( player ) )
            local dias = tonumber( args[ 1 ] );
            local verify, _ = spotify:getPremium( account ) 
            if not verify then
                 spotify:givePremium( account, dias )
            end
        end;
    };
    ['hyperscripts:porte'] = {
        function( player, args )
            local categoria = args[ 1 ]
            local verificar = exports['[HS]Porte_Armas']:verificar_porte( player, categoria )
            if not verificar then
                exports['[HS]Porte_Armas']:set_porte( player, categoria )
            end
        end;
    };
}