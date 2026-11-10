defmodule NodoCliente do
  @nombre_servicio_local :servicio_respuesta
  @servicio_local {:servicio_respuesta, :nodocliente@localhost}
  @nodo_remoto :nodoservidor@localhost
  @servicio_remoto {:servicio_sismos, @nodo_remoto}

  def main() do
    Util.mostrarMensaje("PROCESO PRINCIPAL")

    @nombre_servicio_local
    |> registrar_servicio()

    establecer_conexion(@nodo_remoto)
    |> iniciar_produccion()
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  defp establecer_conexion(nodo_remoto) do
    Node.connect(nodo_remoto)
  end

  defp iniciar_produccion(false),
    do: Util.mostrarMensaje("No se pudo conectar con el nodo servidor")

  defp iniciar_produccion(true) do
    enviar_mensajes()
    recibir_respuestas()
  end

  defp enviar_mensajes() do
    mensajes = [
      {:reporte_ciudad, "C01"},
      {:reporte_ciudad, "C09"},
      {:reporte_ciudad, "C10"},
      :reporte_general,
      :fin
    ]

    Enum.each(mensajes, &enviar_mensaje/1)
  end

  defp enviar_mensaje(solicitud) do
    send(@servicio_remoto, {@servicio_local, solicitud})
  end

  defp recibir_respuestas() do
    receive do
      :fin ->
        IO.puts("All reports received.")

      respuesta ->
        case respuesta do
          {:error, :ciudad_inexistente} ->
            IO.puts("Error: la ciudad solicitada no existe.")

          {:error, {:citys, reason}} ->
            IO.puts("Error al leer el archivo de ciudades: #{inspect(reason)}")

          {:error, {:movements, reason}} ->
            IO.puts("Error al leer el archivo de movimientos: #{inspect(reason)}")

          mensaje when is_binary(mensaje) ->
            IO.puts(mensaje)

          otro ->
            IO.inspect(otro)
        end

        recibir_respuestas()
    end
  end
end

NodoCliente.main()
