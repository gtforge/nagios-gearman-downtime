#!/usr/bin/env ruby

require 'gearman'
require 'base64'
require "openssl"
require "thor"

class Downtime < Thor

  default_task 'send_downtime'

  desc "send_downtime", "Send Downtime request to Gearman server - downtime queue"

  method_option :gearman_server, :desc => 'Gearman server address', :required => true
  method_option :gearman_port,   :desc => 'Gearman server port',                                                     :default => '4730'
  method_option :encryption,     :desc => 'Enable encryption of request( true / false)', :type => 'boolean',         :default => false
  method_option :key,            :desc => 'Key to encrypt request - must be identical to the gearman_server key',    :default => ''
  method_option :queue,          :desc => 'Gearman queue',                                                           :default => 'downtime'

  method_option :object_type,    :desc => 'Object type in nagios',:enum => %w{ host hostgroup_host hostgroup_svc servicegroup_host servicegroup_svc service enable_servicegroup disable_servicegroup}, :default => 'host'
  method_option :object_name,    :desc => 'Name of the object in nagios - default to hostname -f ',                  :default => `hostname -f`.chomp
  method_option :start_time,     :desc => 'Downtime start_time in epoch - default now',                              :default => Time.now.to_i
  method_option :end_time,       :desc => 'Downtime end_time in epoch - default now',                                :default => Time.now.to_i 
  method_option :duration,       :desc => 'duration of downtime in minutes', :required => true                                         
  method_option :fixed,          :desc => 'downtime start and end is fixed',                                         :default => 1
  method_option :author,         :desc => 'Author of downtime (default hostname)',                                   :default => `hostname -f`.chomp
  method_option :comment,        :desc => 'Comment for downtime',                                                    :default => 'Downtime recieved by gearman server'
  method_option :trigger_id,     :desc => 'triggered by the ID of another scheduled downtime entry',                 :default => 0

  def send_downtime

    options[:duration] = options[:duration] * 60
    options[:end_time] = Time.now.to_i + options[:duration]

    args = {
      :gearman_job_server => ["#{options[:gearman_server]}:#{options[:gearman_port] || 4730}"],
      :encryption         => options[:encryption],
      :key                => options[:key],
      :queue              => options[:queue],
      :object_type        => options[:object_type],
      :object_name        => options[:object_name],
      :start_time         => options[:start_time],
      :end_time           => options[:end_time],
      :duration           => options[:duration],
      :fixed              => options[:fixed],
      :author             => options[:author],
      :comment            => options[:comment],
      :trigger_id         => options[:trigger_id]
    }

    args.merge!(:job => build_payload(args))

    send_external_cmd(args)
  end

private
  def create_object_type(obj, obj_name)
    case obj
    when 'host' 
      object_info = "SCHEDULE_HOST_SVC_DOWNTIME;#{obj_name}"
    when 'hostgroup_host' 
      object_info = "SCHEDULE_HOSTGROUP_HOST_DOWNTIME;#{obj_name}"
    when 'hostgroup_svc' 
      object_info = "SCHEDULE_HOSTGROUP_SVC_DOWNTIME;#{obj_name}"
    when 'servicegroup_host' 
      object_info = "SCHEDULE_SERVICEGROUP_HOST_DOWNTIME;#{obj_name}"
    when 'servicegroup_svc' 
      object_info = "SCHEDULE_SERVICEGROUP_SVC_DOWNTIME;#{obj_name}"
    when 'service' 
      object_info = "SCHEDULE_HOSTGROUP_HOST_DOWNTIME;#{obj_name}"
    when 'enable_servicegroup'
      object_info = "ENABLE_SERVICEGROUP_SVC_NOTIFICATIONS;#{obj_name}"
    when 'disable_servicegroup'
      object_info = "DISABLE_SERVICEGROUP_SVC_NOTIFICATIONS;#{obj_name}"
    end

  end


  def build_payload(args)
    object_info = create_object_type(args.delete(:object_type), args.delete(:object_name))
    
    if object_info.match(/enable|disable/i)
      common_args = ''
    else
      common_args = "#{args.delete(:start_time)};#{args.delete(:end_time)};#{args.delete(:fixed)};#{args.delete(:trigger_id)};#{args.delete(:duration)};#{args.delete(:author)};#{args.delete(:comment)}"
    end
    
    payload = "[#{Time.now.to_i}] #{object_info};#{common_args}"

    if args.delete(:encryption)
      begin
        payload = aes256_encrypt(args.delete(:key), payload)
      rescue Exception => e
        puts "unable to encrypt: #{e}"
      end
    end
    payload
  end

  def send_external_cmd(options)
    puts "send_external_cmd options: #{options}"
    client  = ::Gearman::Client.new(options[:gearman_job_server])
    taskset = ::Gearman::TaskSet.new(client)
    encoded_job = Base64.encode64(options[:job])
    task = ::Gearman::Task.new(options[:queue], encoded_job) 
    begin
      puts "[client] Sending task: #{task.inspect}"
      result = taskset.add_task(task)
    rescue Exception => e
      "Send external command failed: #{e}"
    end
  end

  def aes256_encrypt(key, data)
    key = null_padding(key)
    aes = OpenSSL::Cipher.new('AES-256-ECB')
    aes.encrypt
    aes.key = key
    aes.update(data) + aes.final
  end

  def null_padding(key)
    padding = (32 - key.bytesize) if(key.kind_of?(String) && 32 != key.bytesize)
    key += "\0" * padding
  end
end

Downtime.start