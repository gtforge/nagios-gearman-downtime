module Nagios
  module Gearman
    module Downtime

      def self.log
        @@logger = 
        begin          
          Logger.new('/var/log/downtime_worker.log')
         rescue Exception => e
          Logger.new(STDOUT)
         end
        @@logger.level = Logger::DEBUG
        @@logger        
      end

      def self.create_object_type(obj, obj_name)
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
        log.info("object_info: #{object_info}")
      end


      def self.build_payload(args)
        object_info = create_object_type(args.delete(:object_type), args.delete(:object_name))
        
        if object_info.match(/enable|disable/i)
          common_args = ''
        else
          common_args = "#{args.delete(:start_time)};#{args.delete(:end_time)};#{args.delete(:fixed)};#{args.delete(:trigger_id)};#{args.delete(:duration)};#{args.delete(:author)};#{args.delete(:comment)}"
        end
        
        payload = "[#{Time.now.to_i}] #{object_info};#{common_args}"
        log.info("payload before encryption: #{payload}")

        if args.delete(:encryption)
          begin
            payload = aes256_encrypt(args.delete(:key), payload)
          rescue Exception => e
            puts "unable to encrypt: #{e}"
          end
        end
        payload
      end

      def self.send_external_cmd(options)
        log.info "send_external_cmd options: #{options}"
        client  = ::Gearman::Client.new(options[:gearman_job_server])
        taskset = ::Gearman::TaskSet.new(client)
        encoded_job = Base64.encode64(options[:job])
        task = ::Gearman::Task.new(options[:queue], encoded_job) 
        begin
          log.info "[client] Sending task: #{task.inspect}"
          result = taskset.add_task(task)
          log.info("result: #{resault}")
        rescue Exception => e
          log.error "Send external command failed: #{e}"
        end
      end

      def self.aes256_encrypt(key, data)
        key = null_padding(key)
        aes = OpenSSL::Cipher.new('AES-256-ECB')
        aes.encrypt
        aes.key = key
        aes.update(data) + aes.final
      end

      def self.null_padding(key)
        padding = (32 - key.bytesize) if(key.kind_of?(String) && 32 != key.bytesize)
        key += "\0" * padding
      end
    end
  end
end