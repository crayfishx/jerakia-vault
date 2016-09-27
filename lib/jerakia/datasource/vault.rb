require 'jerakia'
require 'vault'

class Jerakia
  class Datasource
    module Vault

      def run

        option :host,       type:  String, default: '127.0.0.1'
        option :port,       type:  Integer, default: 8200
        option :scheme,     type:  Symbol, default: :http
        option :token,      type:  String
        option :searchpath, type:  Array,  default:  [ 'secret' ]
        option :field,      type:  Symbol, default:  lookup.request.key.to_sym
        option :dig,        type:  [FalseClass, TrueClass], default: true
        option :map_key,    type:  [FalseClass, TrueClass], default: false


        addr = "#{options[:scheme].to_s}://#{options[:host]}:#{options[:port]}"

        Jerakia.log.debug("[jerakia-vault]: Using address #{addr}")

        begin
          vault = ::Vault::Client.new
          vault.configure do |conf|
            conf.address = addr
            conf.token   = options[:token] if options[:token]
          end

          sealed = vault.sys.seal_status.sealed?

        rescue ::Vault::HTTPConnectionError => e
          raise Jerakia::Error, "Cannot connect to vault server.  #{e.message}"
        end

        raise Jerakia::Error, "Connected to sealed vault" if sealed

        hierarchy = options[:searchpath].map { |s|
          [s, lookup.request.namespace ].flatten.join("/")
        }

        hierarchy.each do |level|

          # Don't perform any more lookups if Jerakia reports that
          # it doesn't want any more.
          break unless response.want?

          # If map_key option is set then we should append the lookup key to
          # the search path
          level << "/#{lookup.request.key}" if options[:map_key]

          Jerakia.log.debug("[jerakia-vault]: looking up #{level}")

          secret = vault.logical.read(level)

          if secret.is_a?(::Vault::Secret)
            Jerakia.log.debug("[jerakia-vault]: valid answer returned #{secret.data}")

            # If dig is true then we should lookup the key from the hash
            # response, if not then we just return the whole hash
            #
            if options[:dig]
              if result = secret.data[options[:field]]
                Jerakia.log.debug("[jerakia-vault]: found key #{lookup.request.key.to_sym}")
                response.submit result
              end
            else
              response.submit secret.data unless secret.data.empty?
            end
          end
        end
      end
    end
  end
end
