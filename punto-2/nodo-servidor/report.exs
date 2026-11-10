Code.require_file("persistance.exs")

defmodule Report do
  def main do
    "Initializing processing..."
    |> Util.mostrarMensaje()
  end

  def load_data() do
    task_citys =
      Task.async(fn ->
        Persistance.chargeCitys()
      end)

    case Task.await(task_citys) do
      {:error, reason} ->
        {:error, {:citys, reason}}

      citys ->
        task_movements =
          Task.async(fn ->
            Persistance.chargeMovements(citys)
          end)

        case Task.await(task_movements) do
          {:error, reason} ->
            {:error, {:movements, reason}}

          movements ->
            {:ok, movements, citys}
        end
    end
  end

  def generate_city_report(idCity) do
    with {:ok, movements, citys} <- load_data() do
      case Enum.find(citys, fn city -> city.idCity == idCity end) do
        nil ->
          {:error, :ciudad_inexistente}

        city ->
          reports = enumerate_citys(movements, [city])
          generate_report(reports)
      end
    end
  end

  def generate_general_report() do
    with {:ok, movements, citys} <- load_data() do
      reports = enumerate_citys(movements, citys)

      generate_report(reports)
    end
  end

  def enumerate_citys(movements, citys) do
    Enum.map(citys, fn city ->
      city_movements =
        Enum.filter(movements, fn movement ->
          movement.idCity == city.idCity
        end)

      stadistics = calculate_stadistics(city_movements)

      {city, city_movements, stadistics}
    end)
  end

  defp calculate_stadistics(movements) do
    calculate_stadistics(movements, 0, nil, 0)
  end

  defp calculate_stadistics([], cantity, highest_magnitude, sum_depths) do
    promedy =
      if cantity > 0 do
        sum_depths / cantity
      else
        0.0
      end

    {cantity, highest_magnitude, sum_depths, promedy}
  end

  defp calculate_stadistics([movement | rest], cantity, highest_magnitude, sum_depths) do
    new_mayor =
      case highest_magnitude do
        nil ->
          {movement.id, movement.magnitude}

        {_id, magnitud_actual} when movement.magnitude > magnitud_actual ->
          {movement.id, movement.magnitude}

        _ ->
          highest_magnitude
      end

    calculate_stadistics(
      rest,
      cantity + 1,
      new_mayor,
      sum_depths + movement.depth
    )
  end

  def generate_report(reports) do
    reports
    |> Enum.map(fn {city, movements, stadistics} ->
      {cantity, highest_magnitude, _suma, promedio} = stadistics

      movements_list =
        Enum.map(movements, fn movement ->
          """
          ID: #{movement.id}
          Starting Time: #{movement.startingTime}
          Ending Time: #{movement.endingTime}
          Magnitude: #{movement.magnitude}
          Depth: #{movement.depth} km
          """
        end)
        |> Enum.join("\n")

      highest =
        case highest_magnitude do
          nil ->
            "Highest movement magnitude: No apply"

          {id, magnitude} ->
            "Highest movement magnitude: #{id} - #{magnitude}"
        end

      promedy_formated =
        if cantity > 0 do
          :erlang.float_to_binary(promedio * 1.0, decimals: 2) <> " km"
        else
          "No apply"
        end

      """
      City: #{city.name}
      Population: #{city.population}

      Movements list:
      #{movements_list}

      Total Movements: #{cantity}
      #{highest}
      Promedy depth: #{promedy_formated}
      ======================================
      """
    end)
    |> Enum.join("\n")
  end
end

Report.main()
