require 'openssl'

=begin
  TripleDESService is a utility class that handles encryption and decryption

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class TripleDESService
  
  attr_reader :key, :crypto

=begin
  TripleDESService constructor

  @param vs_key a HEX Encoded Key
=end
  def initialize(vs_key)
    @key = vs_key
  end

=begin
  TripleDES encrypts the given string and hex encodes the result

  @param vs_input the string to be encrypted
  @return the encrypted and hex encoded string
=end
  def encrypt(vs_input)
    
    cipher = OpenSSL::Cipher::Cipher::new("des-ede3")
    cipher.encrypt
    cipher.padding = 1
    cipher.key = [@key].pack('H*')
    cipher_result = ""
    cipher_result << cipher.update(vs_input)
    cipher_result << cipher.final
    return cipher_result.unpack('H*')[0]
    
  end
  
=begin
  TripleDES decrypts the given HEX encoded string

  @param vs_input the HEX Encoded string to be decrypted
  @return the decrypted string
=end
  def decrypt(input)
    
    cipher = OpenSSL::Cipher::Cipher::new("des-ede3")
    cipher.decrypt
    cipher.padding = 1
    cipher.key = [@key].pack('H*')
    cipher_result = ""
    cipher_result << cipher.update([input].pack('H*'))
    cipher_result << cipher.final
    return cipher_result
    
  end
  
end
