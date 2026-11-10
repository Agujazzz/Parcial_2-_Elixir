defmodule City do
  defstruct idCity: "", name: "", population: 0

  def createCity(idCity, name, population) when idCity == "" or name == "" or population == "" do
    {idCity, name, population, :empty_field}
  end

  def createCity(idCity, name, population) do
    case Integer.parse(population) do
      {number, ""} when number > 0 ->
        %City{idCity: idCity, name: name, population: number}

      _ ->
        {idCity, name, population, :invalid_number}
    end
  end

  def transform_line_city(line) do
    case String.trim(line) do
      "" ->
        :ignore

      line ->
        case String.split(line, "@") do
          [idCity, name, population] -> createCity(idCity, name, population)
          _ -> {line, :invalid_format}
        end
    end
  end

  def transform_city_line(%City{} = city) do
    "#{city.idCity}@#{city.name}@#{city.population}"
  end

  def transform_city_line({line, reason}) do
    "#{line}@#{reason}"
  end

  def transform_city_line({idCity, name, population, reason}) do
    "#{idCity}@#{name}@#{population}@#{reason}"
  end
end
