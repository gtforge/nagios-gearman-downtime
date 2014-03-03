#!/usr/bin/env ruby
require 'gearman'
require 'base64'
require 'openssl'
require 'logger'

logger = Logger.new(STDOUT)

key = `grep key /etc/mod-gearman/worker.conf`.chomp.split('=').last.strip
logger.info "key: #{key}"

servers = []
servers << `grep server /etc/mod-gearman/worker.conf`.chomp.split('=').last.strip
logger.info "servers: #{servers}"

def aes256_decrypt(key, data)
  key = null_padding(key)
  aes = OpenSSL::Cipher.new('AES-256-ECB')
  aes.decrypt
  aes.key = key
  aes.update(data) + aes.final
end

def null_padding(key)
  padding = (32 - key.bytesize) if(key.kind_of?(String) && 32 != key.bytesize)
  key += "\0" * padding
end


def process_external_cmd(data)
  path = '/var/lib/icinga/rw/icinga.cmd'

  File.open(path, 'a') do |pipe|
    puts "Sending downtime: #{data}"
    pipe.puts data
    pipe.close
  end
end

w = Gearman::Worker.new(['0.0.0.0:4730'])
logger.info w.status

w.add_ability('downtime') do |data,job|
  logger.info "Data recieved:\n#{data}"
  decoded_data  = Base64.strict_decode64(data.gsub("\n", ''))

  decrypt = aes256_decrypt(key, decoded_data)
  logger.info "decrypted data:\n#{decrypt}"

  process_external_cmd(decrypt)
  logger.info "Finished processing job"
end

loop { w.work }