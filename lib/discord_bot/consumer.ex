defmodule DiscordBot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!elixir fn " <> function_string ->
        send_function_info(msg.channel_id, function_string)

      _ ->
        :ignore
    end
  end

  defp send_function_info(channel_id, function_string) do
    # Parse the function string to get the module and function name
    [module_name, function_name] = String.split(function_string, ".", parts: 2)
    function = String.to_atom(function_name)

    # Get documentation for the function
    result = ElixirDocs.get_function_docs(module_name, function)
    Api.create_message(channel_id, result)
  end
end

defmodule ElixirDocs do
  def get_function_docs(module_name, function_name) do
    # Construct the module literal dynamically from the string
    module = :"Elixir.#{module_name}"

    # Fetch the documentation for the module
    case Code.fetch_docs(module) do
      {:error, _reason} ->
        "Module not found or no docs available"

      {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, docs} ->
        docs
        |> Enum.filter(fn
          {{:function, fun, _arrty}, _, _, _, _} ->
            fun == function_name

          {_, _, _, _, _} ->
            false
        end)
        |> case do
          [] ->
            "No documentation found for #{function_name}."

          functions ->
            Enum.map(functions, fn {{:function, fun, arrty}, _, [sig], %{"en" => desc}, _} ->
              "[#{module_name}.#{sig}](https://hexdocs.pm/elixir/1.18.1/#{module_name}.html##{fun}/#{arrty})"
            end)
            |> Enum.join("\n")
        end
    end
  end
end
