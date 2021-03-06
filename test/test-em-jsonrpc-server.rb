#!/usr/bin/ruby
# coding: utf-8

### TMP
$LOAD_PATH.insert 0, File.expand_path(File.join(File.dirname(__FILE__), "../", "lib"))
require "em-jsonrpc/server"


class MyJsonRpcServer < EM::JsonRPC::Server

  def receive_request(request)
    puts "request received:"
    puts "- id     : #{request.id.inspect}"
    puts "- method : #{request.rpc_method.inspect}"
    puts "- params : #{request.params.inspect}"

    case request.rpc_method
    
    when /^(subtract|\-)$/
      if request.params.is_a? Array
        minued = request.params[0].to_i
        subtrahend = request.params[1].to_i
      elsif request.params.is_a? Hash
        minued = request.params[:minuend].to_i
        subtrahend = request.params[:subtrahend].to_i
      end
      result = minued - subtrahend
      request.reply_result(result)

    when /^(sum|\+)$/
      if request.params.is_a? Array
        sum1 = request.params[0].to_i
        sum2 = request.params[1].to_i
      elsif request.params.is_a? Hash
        sum1 = request.params[:minuend].to_i
        sum2 = request.params[:subtrahend].to_i
      end
      result = sum1 + sum2
      request.reply_result(result)

    else
      request.reply_method_not_found
    end
  end

end


EM.run do
  yajl_options = { :symbolize_keys => true }
  
  EM::JsonRPC.start_tcp_server("0.0.0.0", 8888, MyJsonRpcServer, yajl_options) do |conn|
    puts "\nnew TCP connection"
    conn.set_comm_inactivity_timeout 120
  end

  EM::JsonRPC.start_unix_domain_server("/tmp/borrame", MyJsonRpcServer, yajl_options) do |conn|
    puts "\nnew UnixSocket connection"
    conn.set_comm_inactivity_timeout 120
  end
end