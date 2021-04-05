require "bundler/setup"
require 'sinatra'
require "rack/lightning"


LND = Lnrpc::Client.new({
  credentials: ENV['LND_CREDENTIALS'],
  macaroon: ENV['LND_MACAROON'],
  address: ENV['LND_ADDRESS']
})

set :port, 4568
get '/' do
  erb :index
end

get '/402-html' do
  invoice_res = LND.lightning.add_invoice(value: 100, memo: 'I :heart: ruby')
  puts invoice_res.payment_request
  #status 402
  headers 'Content-Type' => 'text/html', 'WWW-Authenticate' => "lsat macaroon=\"hallo\" invoice=\"#{invoice_res.payment_request}\""
  erb :invoice, locals: { invoice: invoice_res }
end

__END__

@@ layout
<!DOCTYPE html>
<html>
  <head>
    <title>402</title>
    <meta charset="utf-8" />
  </head>
  <body><%= yield %></body>
</html>

@@ invoice
<pre><a href="lightning:<%= invoice.payment_request %>">lnbtc...</a></pre>

<script
  src="https://unpkg.com/webln@0.2.0/dist/webln.min.js"
  integrity="sha384-mTReBqbhPO7ljQeIoFaD1NYS2KiYMwFJhUNpdwLj+VIuhhjvHQlZ1XpwzAvd93nQ"
  crossorigin="anonymous"
></script>
<script>
window.addEventListener('DOMContentLoaded', function(event) {
  window.setTimeout(function() {

    WebLN.requestProvider()
      .then(function(webln) {
        return webln.sendPayment('<%= invoice.payment_request %>')
          .then(function(r) {
            console.log('done', r);
          })
          .catch(function(e) {
            console.log('err', e);
          });
    })
    .catch(function(e) { console.log('err, provider', e) });

  }, 300);
});
</script>
