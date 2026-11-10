defmodule Util do

  @moduledoc """
  Módulo con funciones que se reutilizan
  - autor: Daniel Aguja.
  - fecha: 2026-08-09
  - licencia: GNU GPL v3
  """

  def mostrarMensaje(mensaje) do
    IO.puts(mensaje)
  end

  def ingresar(mensaje, :texto) do
  IO.gets(mensaje)
  |>String.trim()
  end

  def ingresar(mensaje, :entero) do
    ingresar(mensaje, &String.to_integer/1, :entero)
  end

  def ingresar(mensaje, :real) do
    ingresar(mensaje, &String.to_float/1, :real)
  end

  #Usar manejo de excepciones para evitar errores al ingresar un valor no entero
  def ingresar(mensaje,parser, tipo_dato) do
    try do
      mensaje
      |>ingresar(:texto)
      |>parser.()
    rescue
      ArgumentError ->
       IO.puts("Error: debes ingresar un número #{tipo_dato}.")
       mensaje
       |>ingresar(parser, tipo_dato)
    end
  end

  def ingresar(mensaje, :booleano) do
    mensaje
    |>ingresar(:texto)
    |>String.downcase()
    |>case do
      "si" -> true
      "no" -> false
      _ ->
        IO.puts("Error: debes ingresar 'si' o 'no'.")
        mensaje
        |>ingresar(:booleano)
    end
  end

end
