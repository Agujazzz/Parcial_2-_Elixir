Code.require_file("city.exs")
Code.require_file("movement.exs")
Code.require_file("csv.exs")

defmodule Persistance do
  @citys_file_name "resources/citys.csv"
  @rejected_citys "resources/rejected_citys.csv"

  @movements_file_name "resources/movements.csv"
  @rejected_movements "resources/rejected_movements.csv"

  @report_file_name "resources/report.csv"

  def chargeCitys() do
    Csv.readCsv(@citys_file_name, &City.transform_line_city/1)
  end

  def chargeMovements(citys) do
    Csv.readCsv(@movements_file_name, fn line -> Movement.transform_line_movement(line, citys) end)
  end

  def saveCitys(citys) do
    Csv.writeCsv(citys, @rejected_citys, &City.transform_city_line/1)
  end

  def saveCitys(citys, :ok) do
    Csv.writeCsv(citys, @citys_file_name, &City.transform_city_line/1)
  end

  def saveMovements(movements) do
    Csv.writeCsv(movements, @rejected_movements, &Movement.transform_movement_line/1)
  end

  def saveMovements(movements, :ok) do
    Csv.writeCsv(movements, @movements_file_name, &Movement.transform_movement_line/1)
  end

  def saveReport(report) do
    Csv.writeCsv(@report_file_name, report)
  end

  def format_citys(citys) do
    {approvedCitys, rejectedCitys, _ids} =
      Enum.reduce(citys, {[], [], MapSet.new()}, fn city, {approved, rejected, ids} ->
        case city do
          %City{idCity: id} = city ->
            if MapSet.member?(ids, id) do
              {approved, [{city.idCity, city.name, city.population, :existent_idCity} | rejected],
               ids}
            else
              {[city | approved], rejected, MapSet.put(ids, id)}
            end

          _ ->
            {approved, [city | rejected], ids}
        end
      end)

    saveCitys(Enum.reverse(approvedCitys), :ok)

    list = Enum.filter(rejectedCitys, &is_tuple/1)

    if list != [] do
      saveCitys(Enum.reverse(list))
    end
  end

  def format_movements(movements) do
    {approvedMovements, rejectedMovements, _ids} =
      Enum.reduce(movements, {[], [], MapSet.new()}, fn movement, {approved, rejected, ids} ->
        case movement do
          %Movement{id: id} = movement ->
            if MapSet.member?(ids, id) do
              {approved,
               [
                 {movement.id, movement.idCity, movement.startingTime, movement.endingTime,
                  movement.magnitude, movement.depth, :existent_id}
                 | rejected
               ], ids}
            else
              {[movement | approved], rejected, MapSet.put(ids, id)}
            end

          _ ->
            {approved, [movement | rejected], ids}
        end
      end)

    saveMovements(Enum.reverse(approvedMovements), :ok)

    list = Enum.filter(rejectedMovements, &is_tuple/1)

    if list != [] do
      saveMovements(Enum.reverse(list))
    end
  end
end
