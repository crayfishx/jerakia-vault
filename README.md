# jerakia-vault

## Description

[_Vault_](http://vaultproject.io) is a secure store for secret data such as passwords, certificates...etc with strict controls on access. 

[_Jerakia_](http://jerakia.io) is a data lookup tool for configuration management systems such as Puppet that supports multiple pluggable datasources


jerakia-vault is a data source for the lookup tool [Jerakia](http://jerakia.io) that reads secret data from [Vault](http://vaultproject.io)

## Requirements

* Vault
* Jerakia

## Installation 

```
#  gem install jerakia-datasource-vault
```


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
* `map_key`: Specifies whether or not to include the lookup key as part of the search path (see lookup behaviour below)
* `dig`: When true, Jerakia will lookup the requested key from the hash returned from vault.  When false, Jerakia will return the entire hash
* `field`: Used when `dig` is true to determine which field should be looked up from the returned hash, this defaults to the lookup key of the request

## Example

### An example policy

```ruby
lookup :default do
  ...

  datasource :vault, {
    host:   '127.0.0.1',
    port:   8200,
    searchpath:  [
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

## Lookup behaviour.

Vault stores data as key value pairs under a path, depending on what structure you decide to store your data you can configure jerakia-vault in one of three waus.

### Individual key lookups

This is the default behaviour of jerakia-vault and assumes you store all your individual lookup keys as fields under the path.  The Jerakia namespace is considered the path and the key is looked up.  To do this we tell jerakia-vault to dig into the returned hash and lookup the field corresponding to the lookup key.

Example:

```
# vault write secret/mysql root_password='wibble' ro_password='tango' rw_password='delta'
```

```
# jerakia lookup rw_password --namespace mysql
"delta"
```
 
### Common field lookup

You could decide to use individual paths to store each configurable element using a shared common field, such as `value`

Example

```
# vault write secret/mysql/root_password value='wibble' 
# vault write secret/mysql/rw_password value='delta' 
# vault write secret/mysql/ro_password value='tango' 
```

In this scenario, we need to tell jerakia-vault to append the lookup key to vault's path.  We do this with the `map_key` attribute.  Also, by default jerakia-vault will try and lookup the field corresponding to the lookup key from the returned hash - in this case, we want to lookup the `value` field, we can override this behaviour with the `field` attribute. 

```ruby
  datasource :vault, {
    map_key: true,
    field:   :value,
  }
```

```
# jerakia lookup rw_password --namespace mysql
"delta"
```

### Hash lookup

The third lookup behaviour supported is to always return the entire hash of data returned from the vault path.  We can tell jerakia-vault not to search for values inside the returned hash and instead just return the entire hash by setting the `dig` attribute to `false`


```
# vault write secret/mysql/passwords root_password='wibble' ro_password='tango' rw_password='delta'
```


```ruby
  datasource :vault, {
    dig: false,
  }
```

```
# bin/jerakia lookup passwords --namespace mysql
{"ro_password":"tango","root_password":"wibble","rw_password":"delta"}
```


## Author

Written and maintained by Craig Dunn <craig@craigdunn.org> @crayfishx

Licensed under Apache 2.0 (see LICENSE)
Copyright 2016 Craig Dunn.


