defmodule Movement do
  defstruct id: "", idCity: "", startingTime: "", endingTime: "", magnitude: 0, depth: 0

  def createMovement(id, idCity, startingTime, endingTime, magnitude, depth, _citys)
      when id == "" or idCity == "" or startingTime == "" or endingTime == "" or magnitude == "" or
             depth == "" do
    {id, idCity, startingTime, endingTime, magnitude, depth, :empty_field}
  end

  def createMovement(id, idCity, startingTime, endingTime, magnitude, depth, citys) do
    if Enum.any?(citys, fn city -> city.idCity == idCity end) do
      validar_movement(id, idCity, startingTime, endingTime, magnitude, depth)
    else
      {id, idCity, startingTime, endingTime, magnitude, depth, :unknown_idCity}
    end
  end

  def validar_movement(id, idCity, startingTime, endingTime, magnitude, depth) do
    with {:ok, _} <- Time.from_iso8601(startingTime),
         {:ok, _} <- Time.from_iso8601(endingTime) do
      case Float.parse(magnitude) do
        {float, ""} when float > 0 ->
          case Integer.parse(depth) do
            {integer, ""} when integer > 0 ->
              %Movement{
                id: id,
                idCity: idCity,
                startingTime: startingTime,
                endingTime: endingTime,
                magnitude: float,
                depth: integer
              }

            _ ->
              {id, idCity, startingTime, endingTime, magnitude, depth, :invalid_depth}
          end

        _ ->
          {id, idCity, startingTime, endingTime, magnitude, depth, :invalid_magnitude}
      end
    else
      _ -> {id, idCity, startingTime, endingTime, magnitude, depth, :invalid_time}
    end
  end

  def transform_movement_line(%Movement{} = movement) do
    "#{movement.id}@#{movement.idCity}@#{movement.startingTime}@#{movement.endingTime}@#{movement.magnitude}@#{movement.depth}"
  end

  def transform_movement_line({line, reason}) do
    "#{line}@#{reason}"
  end

  def transform_movement_line({id, idCity, startingTime, endingTime, magnitude, depth, reason}) do
    "#{id}@#{idCity}@#{startingTime}@#{endingTime}@#{magnitude}@#{depth}@#{reason}"
  end

  def transform_line_movement(line, citys) do
    case String.trim(line) do
      "" ->
        :ignore

      line ->
        case String.split(line, "@") do
          [id, idCity, startingTime, endingTime, magnitude, depth] ->
            createMovement(id, idCity, startingTime, endingTime, magnitude, depth, citys)

          _ ->
            {line, :invalid_format}
        end
    end
  end
end
