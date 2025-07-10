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


-- Globals

local config = config['warp:delivery']

-- Authorization


setTimer( function( )
     authorization( )
end, 1000, 1 )


-- Timer verify

-- Fetch's


authorization = function( )
     fetchRemote('https://api.warpstore.app/api/games/1.0/init',{
          headers = {
               ['Content-Type'] = 'application/json';
               ['Authorization'] = config.token;
          };
          queueName = 'POST'; 
          postData = toJSON({serverPort = getServerPort( )}):gsub("[%[%]]", "")
     },
     function( resposta, erro )
          local resposta = fromJSON( resposta )
          if not erro.success then
               outputDebugString( '[Warp-Delivery] - Sistema desligado, contate a warpstore.', 4, 215, 88, 88 )
               stopResource( getThisResource( ) )
          else
               timer_auth = function( )
                    pending( )
               end
               setTimer( timer_auth, config['tempo:entrega']['tempo'] * config['tempo:entrega']['formato'], config['tempo:entrega']['repetições'] )
               outputDebugString( '✨・[Warp-Store] - Assinatura: ' ..resposta.plan..' | Expira: '..convertStringDate( resposta.expirationDate ), 4, 0, 149, 255 )
          end
     end, '', false )
end

local checkouts = 1
pending = function( )
     fetchRemote('https://api.warpstore.app/api/games/1.0/commands/pending-commands',{
          headers = {
               ['Content-Type'] = 'application/json';
               ['Authorization'] = config.token;
          };
          queueName = 'POST';
          postData = '{}'
     },
     function( resposta, erro )
          if not erro.success then
               return outputDebugString( '[Warp-Delivery] - Erro, contate a warp store.', 4, 215, 88, 88 )
          end
          local resposta = fromJSON( resposta ) or { }
          if resposta.checkouts and #resposta.checkouts > 0 then
               for i, v in pairs( resposta ) do
                    local index = v[ checkouts ]
                    if checkouts > #v then
                         checkouts = 1
                         return
                    end
                    local alvo = getPlayerID( index.gameUserId )
                    if not alvo then
                         checkouts = checkouts + 1
                         return
                    end
                    if index and index.deliveryType == 'APPROVE' then
                         delivery( index.gameUserId, index.products, index.id )
                         checkouts = 1
                    end
               end
          end
     end, '', false)
end


delivery = function( id, args, checkout )
     if args and args[1] and args[1].commands and #args[1].commands == 0 then
          return approve( checkout )
     end
     local alvo = getPlayerID( id )
     if not alvo then
          return
     end
     local avisar = { }
     for i, v in ipairs( args or { } ) do
          for index, name in ipairs( v.commands ) do
               local product = string.match( name, '^[^%s]+' )
               if not product then
                    return outputDebugString( '[Warp-Delivery] - Erro, configure o nome do produto no site corretamente.', 4, 247, 186, 112 )
               end
               if not commands[ product ] then
                    return outputDebugString( '[Warp-Delivery] - Erro, configure o nome do produto e suas exportações → '..product..' no commands.lua.', 4, 247, 186, 112 )
               end
               if type( commands[ product ][ 1 ] ) ~= 'function' then
                    return outputDebugString( '[Warp-Delivery] - Erro, adicione uma função na sua exportação → '..product..' no commands.lua.', 4, 247, 186, 112 )
               end
               if config['entrega']['balões']['ativar'] and not avisar[v.name] then
                    local texto = string.change( config['entrega']['balões']['texto'], { ['name'] = removeHex( getPlayerName( alvo ) ), ['id'] = id, ['product'] = v.name, ['hex'] = config['color:hex'] })
                    createBallons( ( config['entrega']['balões']['visivel'] and root or alvo ), texto, config['entrega']['balões']['quantidade'], (config['entrega']['balões']['tempo'] * config['entrega']['balões']['formato']) )
               end
               if config['entrega']['chatbox']['ativar'] and not avisar[v.name] then
                    local texto = string.change( config['entrega']['chatbox']['texto'], { ['name'] = removeHex( getPlayerName( alvo ) ), ['id'] = id, ['product'] = v.name, ['hex'] = config['color:hex'] })
                    outputChatBox( texto, ( config['entrega']['chatbox']['visivel'] and root or alvo ), config['entrega']['chatbox']['rgb'][1], config['entrega']['chatbox']['rgb'][2], config['entrega']['chatbox']['rgb'][3], true  )
               end
               if config['entrega']['infobox']['ativar'] then
                    local texto = { 
                         ['name'] = removeHex( getPlayerName( alvo ) ), 
                         ['id'] = id, 
                         ['product'] = v.name
                    }
                    config['entrega']['infobox']['notificação'][ 1 ]( ( config['entrega']['infobox']['visivel'] and root or alvo ), texto )
               end
               for i = 1, v.quantity do
                    commands[ product ][ 1 ]( alvo, parseArgs( name ) )
               end
               if config['development']['update:status'] and not avisar[v.name] then
                    approve( checkout )
                    avisar[ v.name ] = true
                    outputDebugString( '[Warp-Delivery] - Produto '..v.name..' foi entregue ao jogador '..removeHex( getPlayerName( alvo ) )..' ('..id..').', 4, 85, 204, 204 )
               end
          end
     end
end


approve = function( command )
     fetchRemote('https://api.warpstore.app/api/games/1.0/commands/mark-as-processed',{
          headers = {
               ['Content-Type'] = 'application/json';
               ['Authorization'] = config.token;
          };
          queueName = 'POST';
          postData = toJSON({commandQueueId = command}):gsub("[%[%]]", "")
     }, 
     function( resposta, erro )
          if not erro.success then
               return outputDebugString( '[Warp-Delivery] - Erro, contate a warp store.', 4, 215, 88, 88 )
          end
     end, '', false)
end


createBallons = function( player, text, ballons, timer )
     triggerClientEvent( player, 'WARP:create:ballons', resourceRoot, text, ballons, timer )
end


-- Util


function parseArgs( str )
     local args = { }
     for arg in string.gmatch(str, "%S+") do
          table.insert(args, arg)
     end
     table.remove( args, 1 )
     table.remove( args, 1 )
     return args
end


function removeHex (s)
     return s:gsub ("#%x%x%x%x%x%x", "") or false
end


function convertStringDate(dataString)
     local data = os.date("*t", os.time{year=string.sub(dataString, 1, 4), month=string.sub(dataString, 6, 7), day=string.sub(dataString, 9, 10), hour=string.sub(dataString, 12, 13), min=string.sub(dataString, 15, 16)})
     local dataFormatada = string.format("%02d/%02d/%d ás %02d:%02d", data.day, data.month, data.year, data.hour, data.min)
     return dataFormatada
end


function string.change (s, t)
     if not s or type (s) ~= 'string' then
          return error ('Bad argument #1 got \''..type (s)..'\'.');
     end
     for w in s:gmatch ('${(%w+)}') do
          s = s:gsub ('${'..w..'}', tostring ((t and t[w]) or 'undefined'));
     end
     return s;
end