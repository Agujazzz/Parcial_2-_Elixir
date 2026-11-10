Code.require_file("persistance.exs")

defmodule Report do
  def main do
    "Initializing processing..."
    |> Util.mostrarMensaje()

    coordinator()
  end

  def coordinator() do
    coordinator = self()

    movement_pid =
      spawn(fn ->
        IO.puts("Processing movements...")
        Process.sleep(3000)

        receive do
          {:citys_ready, citys} ->
            Persistance.chargeMovements(citys)
            |> Persistance.format_movements()

            IO.puts("Movements processed and charged...")

            movements = Persistance.chargeMovements(citys)

            case movements do
              [] ->
                IO.puts("No avaible movements, closing the program...")
                exit(:normal)

              _ ->
                send(coordinator, {:movements_ready, movements, citys})
            end
        end
      end)

    spawn(fn ->
      IO.puts("Processing citys...")
      Process.sleep(3000)

      Persistance.chargeCitys()
      |> Persistance.format_citys()

      IO.puts("Citys processed and charged...")

      citys = Persistance.chargeCitys()

      case citys do
        [] ->
          IO.puts("No avaible citys, closing the program...")
          exit(:normal)

        _ ->
          send(coordinator, {:citys_ready, citys})
      end
    end)

    receive do
      {:citys_ready, citys} ->
        send(movement_pid, {:citys_ready, citys})
    end

    receive do
      {:movements_ready, movements, citys} ->
        enumerate_citys(movements, citys)
    end
  end

  def enumerate_citys(movements, citys) do
    reports =
      Enum.map(citys, fn city ->
        city_movements =
          Enum.filter(movements, fn movement ->
            movement.idCity == city.idCity
          end)

        stadistics = calculate_stadistics(city_movements)

        {city, city_movements, stadistics}
      end)

    generate_report(reports)

    write_report(reports)
    |> Persistance.saveReport()
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
    Enum.each(reports, fn {city, movements, stadistics} ->
      {cantity, highest_magnitude, _suma, promedio} = stadistics

      IO.puts("City: #{city.name}")
      IO.puts("Population: #{city.population}")

      IO.puts("\nMovements list:")

      Enum.each(movements, fn movement ->
        IO.puts("""
        ID: #{movement.id}
        Starting Time: #{movement.startingTime}
        Ending Time: #{movement.endingTime}
        Magnitude: #{movement.magnitude}
        Depth: #{movement.depth} km
        """)
      end)

      IO.puts("Total Movements: #{cantity}")

      case highest_magnitude do
        nil ->
          IO.puts("Highest movement magnitude: No movement")

        {id, magnitude} ->
          IO.puts("Highest movement magnitude: #{id} - #{magnitude}")
      end

      promedy_formated = :erlang.float_to_binary(promedio * 1.0, decimals: 2)

      IO.puts("Promedy depth: #{promedy_formated} km")
      IO.puts("======================================")
    end)
  end

  def write_report(reports) do
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
            "Highest movement magnitude: No movement"

          {id, magnitude} ->
            "Highest movement magnitude: #{id} - #{magnitude}"
        end

      promedy_formated =
        :erlang.float_to_binary(promedio * 1.0, decimals: 2)

      """
      City: #{city.name}
      Population: #{city.population}

      Movements list:
      #{movements_list}

      Total Movements: #{cantity}
      #{highest}
      Promedy depth: #{promedy_formated} km
      ======================================
      """
    end)
    |> Enum.join("\n")
  end
end

Report.main()
