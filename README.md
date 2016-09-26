# jerakia-vault

## Description

jerakia-vault is a data source for the lookup tool [Jerakia](http://jerakia.io) that reads secret data from [Vault](http://vaultproject.io)

## Requirements

* Vault
* Jerakia

## Reference 

### Usage

Jerakia vault can be configured inside a Jerakia lookup as a datasource.  [See the Jerakia documentation](http://jerakia.io/lookups/) for more information on writing Jerakia lookups.  `jerakia-vault` can be configured with all default values as:

```ruby
lookup :default do
  ...
  datasource :vault
end
```

### Parameters

The vault datasource takes a number of parameters:

* `host`: The vault host to connect to, default: `127.0.0.1`
* `port`: The port to use for connecting to vault, default: `8200`
* `schema`: The URL scheme to use, default: `http`
* `token`: An optional token to use for authentication, if not supplied, vault will attempt to read the `VAULT_TOKEN` environment variable
* `searchpath`: An array of search paths to be queried in order, by default this is set to `[ 'secret' ]`


## Example

### An example policy

```ruby
lookup :default do
  ...

  datasource :vault, {
    :host => '127.0.0.1',
    :port => 8200,
    :searchpath => [
      'secret/#{scope[:environment]}',
      'secret/common',
    ]
  }
```


### Add vault data

`jerakia/vault` quieres vault for a record made up of the searchpath and the namespace of the request, the key is then looked up from the corresponding key/value pairs that are returned.

```
# vault write secret/production/mysql password='bar'
```

### Query from Jerakia

```
# jerakia lookup password --namespace mysql --metadata environment:production
"bar"
```



