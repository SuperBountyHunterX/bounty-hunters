defmodule Elbuencoffi.M2x do

  alias M2X.Client
  alias M2X.Device

  @client %Client{ api_key: "975e11c045d480e8779245258228f109" }

  def client do
    @client
  end

  def delete_all_devices! do
    Device.search(client) |> Enum.map(&delete_device!/1)
  end

  def delete_device!(%Device{client: client, attributes: %{"id" => id}}) do
    Client.delete client, "/devices/#{id}"
  end

  def create_player_device(phone, nickname) do
    response = Client.post client, "/devices", %{
      "name" => phone,
      "description" => nickname,
      "visibility" => "public",
      "tags" => "player"
    }
    %{json: %{"id" => id}} = response
    id
  end

  def create_place_device(name, latitude, longitude) do
    response = Client.post client, "/devices", %{
      "name" => name,
      "description" => name,
      "visibility" => "public",
      "tags" => "place"
    }
    %{json: %{"id" => id}} = response
    update_location(id, latitude, longitude)
    id
  end

  def update_location(device_id, latitude, longitude) do
    response = client |> Client.put("/devices/#{device_id}/location", %{
      "latitude" => latitude,
      "longitude" => longitude
    })
  end

  def device_near_location(tags, latitude, longitude, distance \\ 50, unit \\ "m") do
    Device.search(client, %{
      location: %{
        within_circle: %{
          center: %{ latitude: latitude, longitude: longitude },
          radius: Map.put(%{}, unit, distance)
        }
      }
    }) || []
  end

end