class QuitHandler

  def handle (client, message)
   client.quit(message) 
  end
end
