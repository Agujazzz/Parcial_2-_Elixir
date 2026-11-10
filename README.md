Punto 1: elixir .\report.exs 
    - reporte se genera en resources/report.csv

Punto 2: Primero iniciamos la cookie ejecutando elixir .\cookie.exs en nodo-servidor, después creamos un 
    archivo cookie.txt en ambos nodos, junto con la dirección que haya generado el comando.
    Una vez la cookie este en ambos nodos, ejecutamos cada nodo con los siguientes comandos
    En nodo-cliente:
    ```
    elixir --sname nodocliente@cliente --cookie cookie nodo-cliente.exs
    ```
    En nodo-servidor:
    ```
    elixir --sname nodoservidor@localhost --cookie cookie nodo-servidor.exs
    ```
    nodo-cliente solo se ejecutara si nodo-servidor esta activo

Punto 3:

Se usaron los siguientes identificadores

mensajes = [
  {:reporte_ciudad, "C01"},
  {:reporte_ciudad, "C09"},
  {:reporte_ciudad, "C10"},
  :reporte_general,
  :fin
]
```
Para hacer una segunda llamada, basta con ejecutar nuevamente el nodo-cliente, ya que nodo-servidor siempre esta en modo espera
````

Reflexión

1. Use ChatGPT a lo largo de la actividad para solucionar errores de logica y sintaxis, ayuda con los Enum.map y para el manejo de archivos CSV. 

2. En un momento solicite ayuda con la conexión entre nodos, ya que nodo-servidor no recibía los mensajes del cliente.
En donde actualmente tenía:
```
@servicio_local {:servicio_respuesta, :nodocliente@cliente}
@nodo_remoto :nodoservidor@localhost
```
La IA me recomendo cambiar los valores en @servicio_local por:
```
@servicio_local {:servicio_respuesta, :nodocliente@localhost}
@nodo_remoto :nodoservidor@localhost
```
Una vez solucionado el problema de la conexión, tanto servidor y cliente recibian y enviaban sus respectivos mensajes

3. No aplique nada visto fuera de clase, y la IA solo me recomendo temas que yo reconociera y haya visto en clase.

4. En conclusión, gran parte de los temas tratados a lo largo del curso me quedan claros, logica de elixir, patter matching, guardas, structs o "manejo de la informacón" etc. Entre los temas que aún me cuestan, incluiría concurrencia (No tanto en spawn, send o receive, pero si en Task.await y Task.sync), funciones recurrentes por su logíca (Mayormente errores de sintaxis), conexiones entre nodos (Dificil de depurar y entender sus errores).
Cambiaría el uso de CSV o tener que aplicar persistencia, ya que cualquier error con la lectura o el archivo provocan que el programa se congele o directamente deje de funcionar.