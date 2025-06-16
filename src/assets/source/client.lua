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


-- Resolution

cache = {
     render = { };
     functions = { };
}
util = cache.functions

screenWidth, screenHeight = guiGetScreenSize( )
scale = 1

if ( screenHeight <= 480 ) then
     scale = 0.7
elseif ( screenHeight <= 576 ) then
     scale = 0.8
elseif ( screenHeight <= 600 ) then
     scale = 0.9
elseif ( screenHeight <= 720 ) or ( screenHeight <= 768 ) then
     scale = 1
elseif ( screenHeight <= 900 ) then
     scale = 1.1
elseif ( screenHeight <= 1050 ) then
     scale = 1.15
else
     scale = math.min (math.max (0.75, (screenHeight / 768)), 1.2)
end

parentWidth, parentHeight = (916 * scale), (431 * scale)
parentX, parentY = (screenWidth - parentWidth) / 2, (screenHeight - parentHeight) / 2


function respc (value)
     return value * scale
end


function reMap (parent, value)
     return (parent + (value * scale))
end;


_dxDrawText = dxDrawText
function dxDrawText(calculoX, calculoY, text, x, y, w, h, ...)
     local x, y, w, h = reMap(calculoX, x), reMap(calculoY, y), respc(w), respc(h)
     return _dxDrawText(text, x, y, x + w, y + h, ...)
end


_dxCreateFont = dxCreateFont
function dxCreateFont( filePath, size, ... )
     return _dxCreateFont( filePath, ( size ), ... )
end


local cache_font = { }

fonts = function(font, size)
     if (not cache_font[font]) then
          cache_font[font] = { }
     end
     if (not cache_font[font][size]) then
          cache_font[font][size] = _dxCreateFont('src/assets/fonts/'..font, (size * scale) * (72 / 96), false, 'cleartype') or 'default-bold'
     end
     return cache_font[font][size]
end


util.isRender = function( name )
     if isTimer( cache.render[ name ] ) then
          return true
     end
     return false
end


util.createRender = function( name, value )
     if util.isRender( name )then
          return false
     end
     cache.render[ name ] = setTimer( name, value, 0 )
end


util.destroyRender = function( name )
     if isTimer( cache.render[ name ] ) then
          killTimer( cache.render[ name ] )
          name( )
          cache.render[ name ] = nil
     end
end


-- Browser


local browser = createBrowser(screenWidth, screenHeight, true, true)
local visible
setBrowserRenderingPaused( browser, false )


function renderBrowser( )
     dxDrawImage(0, 0, screenWidth, screenHeight, browser)
     dxDrawText( parentX, parentY, message or 'Não encontrado', 161, 165, 594, 69, tocolor( unpack( config['entrega']['balões']['rgb'] ) ), 1.0, fonts( config['entrega']['balões']['font'], config['entrega']['balões']['size'] ), 'center', 'center', false, false, false, true )
end


addEventHandler('onClientBrowserCreated', resourceRoot, function( ) 
     loadBrowserURL( source, 'http://mta/local/src/assets/html/index.html' )
end)


addEventHandler('onClientResourceStop', resourceRoot, function( ) 
     if isElement( browser ) then 
          destroyElement( browser )
     end
end)


function createBallons( text, value, time )
     message = text
     if not tonumber( value ) and util.isRender( renderBrowser ) then 
          return 
     end
     local time = (time and time or 3000)
     util.createRender( renderBrowser, 0 )
     setBrowserRenderingPaused( browser, false )
     executeBrowserJavascript( browser, 'createBalloons('..tostring(value)..')' )
     setTimer(function( )
          executeBrowserJavascript(browser, 'removeBalloons()')
          util.destroyRender( renderBrowser )
          setBrowserRenderingPaused( browser, true )
     end, time, 1)
end


function destroyBallons( )
     if visible then
          visible = false 
          executeBrowserJavascript(browser, 'removeBalloons()')
          removeEventHandler('onClientRender', root, renderBrowser)
          setBrowserRenderingPaused( browser, true )
     end
end


-- Event Custom


createEvent = function( event, ... )
     addEvent( event, true )
     addEventHandler( event, ... )
end


createEvent('WARP:create:ballons', resourceRoot, function( text, ballons, timer )
     createBallons( text, ballons, timer )
end)