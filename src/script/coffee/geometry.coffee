Game.Geometry =
  getLine: (startX, startY, endX, endY) ->
    points = []
    dx = Math.abs(endX - startX)
    dy = Math.abs(endY - startY)
    sx = if startX < endX then 1 else -1
    sy = if startY < endY then 1 else -1
    err = dx - dy
    e2 = undefined

    loop
      points.push({x: startX, y: startY})
      if startX == endX and startY == endY
        break
      e2 = err * 2
      if e2 > (-1 * dx)
        err -= dy
        startX += sx
      if e2 < dx
        err += dx
        startY += sy

    return points
