class KickHandler
  
  def handle(client, user)
    client.kick(user)
  end
end
