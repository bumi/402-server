require "bundler/setup"
require "rack/lightning"

Fourohtwo = Rack::Builder.new {
  map "/" do
    run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['Hello Hello']] }
  end
  map "/402-static" do
    # use Rack::Lightning
    run Proc.new { |env| ['402', {'Content-Type' => 'application/vnd.lightning.bolt11'}, ['invoice goes here']] }
  end
  map "/402" do
    use Rack::Lightning, { credentials: ENV['LND_CREDENTIALS'], macaroon: ENV['LND_MACAROON'], address: ENV['LND_ADDRESS'] }
    run Proc.new { |env| ['402', {'Content-Type' => 'text/html'}, ['thank you lightning!']] }
  end
}.to_app

