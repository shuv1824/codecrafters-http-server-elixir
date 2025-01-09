defmodule Server do
  use Application

  def start(_type, _args) do
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  def listen() do
    # Since the tester restarts your program quite often, setting SO_REUSEADDR
    # ensures that we don't run into 'Address already in use' errors
    port = 4221

    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, active: false, reuseaddr: true]
      )

    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        IO.puts("connection established")
        data = :unicode.characters_to_binary("HTTP/1.1 200 OK\r\n\r\n")
        :gen_tcp.send(client, data)

      other ->
        IO.puts("could not establish connection")
        other
    end
  end
end

defmodule CLI do
  def main(_args) do
    # Start the Server application
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)

    # Run forever
    Process.sleep(:infinity)
  end
end
