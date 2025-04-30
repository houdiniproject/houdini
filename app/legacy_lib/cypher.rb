# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "openssl"

# This module is useful for encrypting columns into the database
# For the encrypted column, store it as "text" types

# .key is stored in ENV['CYPHER_KEY']
# .iv, .auth_tag both are stored with the encrypted data

module Cypher
  def self.encrypt(data)
    cipher = create_cipher
    cipher.encrypt
    cipher.key = Base64.decode64(ENV["CYPHER_KEY"])
    iv = cipher.random_iv
    encrypted = cipher.update(data) + cipher.final
    {iv: Base64.encode64(iv), key: Base64.encode64(encrypted)}
  end

  # hash must have properties for :iv and :key
  def self.decrypt(hash)
    iv, encrypted = [Base64.decode64(hash["iv"]), Base64.decode64(hash["key"])]
    decipher = create_cipher
    decipher.decrypt
    decipher.key = Base64.decode64(ENV["CYPHER_KEY"])
    decipher.iv = iv

    decipher.update(encrypted) + decipher.final
  end

  private

  def self.create_cipher
    OpenSSL::Cipher.new("aes-256-cbc")
  end
end
