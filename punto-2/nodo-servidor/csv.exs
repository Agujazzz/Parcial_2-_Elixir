defmodule Csv do

  def writeCsv(data, file_path, parser) do

    generateCsv(data, parser)
    |> (&File.write(file_path, &1)).()

  end

  def writeCsv(file_path, data) do
    File.write(file_path, data)
  end

  def generateCsv(data, parser) do
    data
    |> Enum.map(parser)
    |> Enum.join("\n")
  end

  def readCsv(file_path, parser) do
    File.stream!(file_path)
    |>Enum.map(parser)
  end

end
