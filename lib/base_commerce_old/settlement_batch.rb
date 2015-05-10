=begin
  SettlementBatch is an entity class that defines attributes of a Settlement Batch.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class SettlementBatch
  
  attr_accessor :bank_account_transaction_credit_amount, :bank_account_transaction_credit_count, :bank_account_transaction_debit_amount,
    :bank_account_transaction_debit_count, :bank_card_transaction_sale_amount, :bank_card_transaction_sale_count, :bank_card_transaction_credit_amount,
    :bank_card_transaction_credit_count, :bank_account_transaction_ids, :bank_card_transaction_ids
  
  # Default Constructor
  def initialize
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :settlement_batch
  end
  
=begin
  Updates the key with the objects json prefix

  @return the updated json key
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def get_qualified_key(key)
      "#{json_prefix}_#{key}".to_sym
  end
  
=begin
  Returns a JSON representation of the SettlementBatch

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json
      hash = {}
      self.instance_variables.each do |var|
        var_text = var[1..-1]
        hash[get_qualified_key(var_text)] = self.instance_variable_get var
      end
      hash.to_json
  end
  
=begin
  Builds and Returns an SettlementBatch object based off of the JSON input.

  @param vo_json   JSON representation of an SettlementBatch
  @return  the SettlementBatch
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(string)
      JSON.load(string).each do |var, val|
          var = "@" + var[17..-1]
          self.instance_variable_set(var, val)
      end
  end
  
end
