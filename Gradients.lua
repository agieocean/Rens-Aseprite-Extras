function drawRadialGradient(centerx, centery, innerColor, outerColor)
    for y=0,app.activeImage.height do
        for x=0,app.activeImage.width do
            if app.activeSprite.selection:contains(x, y) then
                --print(x)
                --print(y)
                --print(app.activeCel.image.width)
                --Find the distance to the center
                distanceToCenter = math.sqrt(
                    (((x-app.activeSprite.selection.bounds.x) - app.activeSprite.selection.bounds.width/2)^2)
                    + (((y-app.activeSprite.selection.bounds.y) - app.activeSprite.selection.bounds.height/2)^2)
                )

                --Make it on a scale from 0 to 1
                distanceToCenter = tonumber(distanceToCenter) / (math.sqrt(2) * app.activeSprite.selection.bounds.height/2)

                --Calculate r, g, and b values
                r = outerColor.red * distanceToCenter + innerColor.red * (1 - distanceToCenter)
                g = outerColor.green * distanceToCenter + innerColor.green * (1 - distanceToCenter)
                b = outerColor.blue * distanceToCenter + innerColor.blue * (1 - distanceToCenter)
                a = outerColor.alpha * distanceToCenter + innerColor.alpha * (1 - distanceToCenter)


                --Place the pixel        
                app.activeImage:drawPixel(x, y, app.pixelColor.rgba(r, g, b, a))
            end
        end
    end
end

local dlg = Dialog()
dlg:entry{ id="centerx", label="Center X:", text="0", decimals=false }
dlg:entry{ id="centery", label="Center Y:", text="0", decimals=false }
dlg:color{
    id="centercolor",
    label="Center color:",
    color=Color{ r=255, g=255, b=0, a=255 }
}
dlg:color{
    id="edgecolor",
    label="Edge color:",
    color=Color{ r=0, g=255, b=255, a=255 }
}
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()
local data = dlg.data
if data.ok then
  x = tonumber(data.centerx)
  y = tonumber(data.centery)
  drawRadialGradient(x, y, data.centercolor, data.edgecolor)
  app.alert("ok dumbass")
end