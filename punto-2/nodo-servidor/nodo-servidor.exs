Code.require_file("report.exs")

defmodule NodoServidor do
  @nombre_servicio_local :servicio_sismos

  def main() do
    Util.mostrarMensaje("PROCESO SECUNDARIO")
    registrar_servicio(@nombre_servicio_local)
    esperar_solicitudes()
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  defp esperar_solicitudes() do
    receive do
      {destino_respuesta, {:reporte_ciudad, idCity}} ->
        respuesta = Report.generate_city_report(idCity)

        send(destino_respuesta, respuesta)

        esperar_solicitudes()

      {destino_respuesta, :reporte_general} ->
        respuesta = Report.generate_general_report()

        send(destino_respuesta, respuesta)

        esperar_solicitudes()

      {destino_respuesta, :fin} ->
        send(destino_respuesta, :fin)

        esperar_solicitudes()
    end
  end
end

NodoServidor.main()
