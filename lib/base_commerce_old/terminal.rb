require_relative "address.rb"

=begin
  This class represents a Terminal in the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class Terminal
  
  
def self.xs_signature_floor_limit_25
	'$25'
end
 
def self.xs_signature_floor_limit_50
	'$50'
end
 
def self.xs_signature_floor_limit_none
	'None'
end
 
def self.xs_model_type_iwl250_retail
	'IWL250 Retail'
end
 
def self.xs_model_type_iwl220_retail
	'IWL220 Retail'
end
 
def self.xs_model_type_iwl250_restaurant
	'IWL250 Restaurant'
end
 
def self.xs_model_type_iwl220_restaurant
	'IWL220 Restaurant'
end
 
def self.xs_model_type_ict250_restaurant
	'ICT250 Restaurant'
end
 
def self.xs_model_type_ict220_restaurant
	'ICT220 Restaurant'
end
 
def self.xs_model_type_ict250_retail
	'ICT250 Retail'
end
 
def self.xs_model_type_ict220_retail
	'ICT220 Retail'
end
 
def self.xs_model_type_t4220_restaurant
	'T4220 Restaurant'
end
 
def self.xs_model_type_t4210_restaurant
	'T4210 Restaurant'
end
 
def self.xs_model_type_t4205_restaurant
	'T4205 Restaurant'
end
 
def self.xs_model_type_t4220_retail
	'T4220 Retail'
end
 
def self.xs_model_type_t4210_retail
	'T4210 Retail'
end
 
def self.xs_model_type_t4205_retail
	'T4205 Retail'
end
 
def self.xs_model_type_nurit_8400_restaurant
	'NURIT 8400 Restaurant'
end
 
def self.xs_model_type_nurit_8400l_restaurant
	'NURIT 8400L Restaurant'
end
 
def self.xs_model_type_nurit_8320_restaurant
	'NURIT 8320 Restaurant'
end
 
def self.xs_model_type_nurit_8100_restaurant
	'NURIT 8100 Restaurant'
end
 
def self.xs_model_type_nurit_8020_restaurant
	'NURIT 8020 Restaurant'
end
 
def self.xs_model_type_nurit_8000_secure_restaurant
	'NURIT 8000Secure Restaurant'
end
 
def self.xs_model_type_nurit_8000_restaurant
	'NURIT 8000 Restaurant'
end
 
def self.xs_model_type_nurit_3020_restaurant
	'NURIT 3020 Restaurant'
end
 
def self.xs_model_type_nurit_3010_restaurant
	'NURIT 3010 Restaurant'
end
 
def self.xs_model_type_nurit_2085_plus_retaurant
	'NURIT 2085+ Restaurant'
end
 
def self.xs_model_type_nurit_2085_restaurant
	'NURIT 2085 Restaurant'
end
 
def self.xs_model_type_nurit_8400_retail
	'NURIT 8400 Retail'
end
 
def self.xs_model_type_nurit_8400l_retail
	'NURIT 8400L Retail'
end
 
def self.xs_model_type_nurit_8320_retail
	'NURIT 8320 Retail'
end
 
def self.xs_model_type_nurit_8100_retail
	'NURIT 8100 Retail'
end
 
def self.xs_model_type_nurit_8020_retail
	'NURIT 8020 Retail'
end
 
def self.xs_model_type_nurit_8000_secure_retail
	'NURIT 8000Secure Retail'
end
 
def self.xs_model_type_nurit_8000_retail
	'NURIT 8000 Retail'
end
 
def self.xs_model_type_nurit_3020_retail
	'NURIT 3020 Retail'
end
 
def self.xs_model_type_nurit_3010_retail
	'NURIT 3010 Retail'
end
 
def self.xs_model_type_nurit_2085_plus_retail
	'NURIT 2085+ Retail'
end
 
def self.xs_model_type_nurit_2085_retail
	'NURIT 2085 Retail'
end
 
def self.xs_model_type_tranz_460_restaurant
	'TRANZ 460 Restaurant'
end
 
def self.xs_model_type_tranz_380_restaurant
	'TRANZ 380 Restaurant'
end
 
def self.xs_model_type_tranz_330_track2_restaurant
	'TRANZ 330 (Track 2) Restaurant'
end
 
def self.xs_model_type_tranz_460_retail
	'TRANZ 460 Retail'
end
 
def self.xs_model_type_tranz_380_retail
	'TRANZ 380 Retail'
end
 
def self.xs_model_type_tranz_330_track2_retail
	'TRANZ 330 (Track 2) Retail'
end
 
def self.xs_model_type_vx570_restaurant
	'Vx570 Restaurant'
end
 
def self.xs_model_type_vx670_gprs_restaurant
	'Vx670 GPRS Restaurant'
end
 
def self.xs_model_type_vx610_gprs_restaurant
	'Vx610 GPRS Restaurant'
end
 
def self.xs_model_type_vx670_wifi_restaurant
	'Vx670 Wifi Restaurant'
end
 
def self.xs_model_type_vx610_wifi_restaurant
	'Vx610 Wifi Restaurant'
end
 
def self.xs_model_type_vx510_dc_restaurant
	'Vx510 DC Restaurant'
end
 
def self.xs_model_type_vx510_gprs_restaurant
	'Vx510 GPRS Restaurant'
end
 
def self.xs_model_type_vx510_restaurant
	'Vx510 Restaurant'
end
 
def self.xs_model_type_vx510_le_restaurant
	'Vx510LE Restaurant'
end
 
def self.xs_model_type_omni_3730_restaurant
	'Omni 3730 Restaurant'
end
 
def self.xs_model_type_omni_3730_le_restaurant
	'OMNI 3730LE Restaurant'
end
 
def self.xs_model_type_omni_3750_restaurant
	'OMNI 3750 Restaurant'
end
 
def self.xs_model_type_omni_3740_restaurant
	'Omni 3740 Restaurant'
end
 
def self.xs_model_type_vx570_retail
	'Vx570 Retail'
end
 
def self.xs_model_type_vx670_gprs_retail
	'Vx670 GPRS Retail'
end
 
def self.xs_model_type_vx610_gprs_retail
	'Vx610 GPRS Retail'
end
 
def self.xs_model_type_vx670_wifi_retail
	'Vx670 Wifi Retail'
end
 
def self.xs_model_type_vx610_wifi_retail
	'Vx610 Wifi Retail'
end
 
def self.xs_model_type_vx510_dc_retail
	'Vx510 DC Retail'
end
 
def self.xs_model_type_vx510_gprs_retail
	'Vx510 GPRS Retail'
end
 
def self.xs_model_type_vx510_retail
	'Vx510 Retail'
end
 
def self.xs_model_type_vx510_le_retail
	'Vx510LE Retail'
end
 
def self.xs_model_type_omni_3730_retail
	'Omni 3730'
end
 
def self.xs_model_type_omni_3730_le_retail
	'OMNI 3730LE Retail'
end
 
def self.xs_model_type_omni_3750_retail
	'OMNI 3750 Retail'
end
 
def self.xs_model_type_omni_3740_retail
	'Omni 3740 Retail'
end
 
def self.xs_model_type_t7e_restaurant
	'T7E Restaurant'
end
 
def self.xs_model_type_t8_restaurant
	'T8 Restaurant'
end
 
def self.xs_model_type_t7_plus_restaurant
	'T7Plus Restaurant'
end
 
def self.xs_model_type_t77_restaurant
	'T77 Restaurant'
end
 
def self.xs_model_type_t7p_restaurant
	'T7P Restaurant'
end
 
def self.xs_model_type_t8_retail
	'T8 Retail'
end
 
def self.xs_model_type_t7e_retail
	'T7E Retail'
end
 
def self.xs_model_type_t7_plus_retail
	'T7Plus Retail'
end
 
def self.xs_model_type_t77_retail
	'T77 Retail'
end
 
def self.xs_model_type_t7p_retail
	'T7P Retail'
end
 
def self.xs_model_type_m4240_restaurant
	'M4240 Restaurant'
end
 
def self.xs_model_type_m4230_restaurant
	'M4230 Restaurant'
end
 
def self.xs_model_type_t4230_restaurant
	'T4230 Restaurant'
end
 
def self.xs_model_type_m4240_retail
	'M4240 Retail'
end
 
def self.xs_model_type_m4230_retail
	'M4230 Retail'
end
 
def self.xs_model_type_t4230_retail
	'T4230 Retail'
end
 
def self.xs_model_type_omni_3210_se_restaurant
	'Omni 3210SE Restaurant'
end
 
def self.xs_model_type_omni_3210_restaurant
	'Omni 3210 Restaurant'
end
 
def self.xs_model_type_omni_3200_se_restaurant
	'Omni 3200SE Restaurant'
end
 
def self.xs_model_type_omni_3200_restaurant
	'Omni 3200 Restaurant'
end
 
def self.xs_model_type_omni_396_restaurant
	'Omni 396 Restaurant'
end
 
def self.xs_model_type_omni_3210_se_retail
	'Omni 3210SE Retail'
end
 
def self.xs_model_type_omni_3210_retail
	'Omni 3210 Retail'
end
 
def self.xs_model_type_omni_3200_se_retail
	'Omni 3200SE Retail'
end
 
def self.xs_model_type_omni_3200_retail
	'Omni 3200 Retail'
end
 
def self.xs_model_type_omni_396_retail
	'Omni 396 Retail'
end
 
def self.xs_model_type_tranz_380_128k_restaurant
	'TRANZ 380 128K Restaurant'
end
 
def self.xs_model_type_tranz_380_64k_restaurant
	'TRANZ 380 64K Restaurant'
end
 
def self.xs_model_type_tranz_380_128k_retail
	'TRANZ 380 128K Retail'
end
 
def self.xs_model_type_tranz_380_64k_retail
	'TRANZ 380 64K Retail'
end
 
def self.xs_model_type_tranz_330_track1_retail
	'TRANZ 330 (Track 1) Retail'
end
 
def self.xs_model_type_tranz_330_restaurant
	'TRANZ 330 Restaurant'
end
 
def self.xs_model_type_tranz_330_retail
	'TRANZ 330 Retail'
end
 
def self.xs_model_type_id_tech_shuttle
	'ID Tech Shuttle'
end
 
def self.xs_model_type_mini_micr
	'Mini MICR'
end
 
def self.xs_model_type_pin_pad
	'Pin Pad'
end
 
def self.xs_model_type_pc
	'PC'
end
 
def self.xs_connection_type_dial
	'Dial'
end
 
def self.xs_connection_type_dual
	'Dual'
end
 
def self.xs_connection_type_ethernet
	'Ethernet'
end
 
def self.xs_connection_type_gprs
	'GPRS'
end
 
def self.xs_implementation_new_bc
	'New (BC)'
end
 
def self.xs_implementation_new_agent
	'New (Agent)'
end
 
def self.xs_implementation_reprogram
	'Reprogram'
end
 
def self.xs_billing_agent
	'Agent'
end
 
def self.xs_billing_azura
	'Azura'
end
 
def self.xs_billing_merchant
	'Merchant'
end
 
def self.xs_billing_rent
	'Rent'
end
 
def self.xs_billing_lease
	'Lease'
end
 
def self.xs_auto_batch_time_3_pm
	'3 pm'
end
 
def self.xs_auto_batch_time_3_30_pm
	'3:30 pm'
end
 
def self.xs_auto_batch_time_4_pm
	'4 pm'
end
 
def self.xs_auto_batch_time_4_30_pm
	'4:30 pm'
end
 
def self.xs_auto_batch_time_5_pm
	'5 pm'
end
 
def self.xs_auto_batch_time_5_30_pm
	'5:30 pm'
end
 
def self.xs_auto_batch_time_6_pm
	'6 pm'
end
 
def self.xs_auto_batch_time_6_30_pm
	'6:30 pm'
end
 
def self.xs_auto_batch_time_7_pm
	'7 pm'
end
 
def self.xs_auto_batch_time_7_30_pm
	'7:30 pm'
end
 
def self.xs_auto_batch_time_8_pm
	'8 pm'
end
 
def self.xs_auto_batch_time_8_30_pm
	'8:30 pm'
end
 
def self.xs_auto_batch_time_9_pm
	'9 pm'
end
 
def self.xs_auto_batch_time_9_30_pm
	'9:30 pm'
end
 
def self.xs_auto_batch_time_10_pm
	'10 pm'
end
 
def self.xs_auto_batch_time_10_30_pm
	'10:30 pm'
end
 
def self.xs_auto_batch_time_11_pm
	'11 pm'
end
 
def self.xs_auto_batch_time_11_30_pm
	'11:30 pm'
end
 
def self.xs_auto_batch_time_12_am
	'12 am'
end
 
def self.xs_auto_batch_time_12_30_am
	'12:30 am'
end
 
def self.xs_auto_batch_time_zone_pt
	'PT'
end
 
def self.xs_auto_batch_time_zone_mt
	'MT'
end
 
def self.xs_auto_batch_time_zone_ct
	'CT'
end
 
def self.xs_auto_batch_time_zone_et
	'ET'
end
 
def self.xs_manufacturer_verifone
	'VeriFone'
end
 
def self.xs_manufacturer_hypercom
	'Hypercom'
end
 
def self.xs_manufacturer_ingenico
	'Ingenico'
end
 
  attr_accessor :tip_line,:auto_batch_terminal,:signature_floor_limit,:model_type,:quantity,:connection_type,:implementation,:billing,:shipping_address,:auto_batch_time,:auto_batch_time_zone,:descriptor,:manufacturer,:software,:ach_processor_id,:bc_processor_id,:company_name_descriptor
  
=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    
    @tip_line = false
    @auto_batch_terminal = false
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :terminal
  end
  
=begin
  Updates the key with the objects json prefix

  @return the updated json key
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def get_qualified_key(key)
      "#{json_prefix}_#{key}".to_sym
  end
  
=begin
  Returns a json object representation of the Terminal
  @params Options any options for modifying the output JSON
  @returns The json representation of this Terminal
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        
        var_text = var[1..-1]
        
        if var_text == "shipping_address"
          
          o_addr = self.instance_variable_get var
          hash[get_qualified_key(var_text)] = o_addr
          
        else
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      return hash.to_json
end

=begin
  Builds an Terminal object based off of the JSON input.

  @param vo_json   JSON representation of an Terminal object
  @return  the Terminal object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
    
      s_prefix = "terminal"
      
      o_addr = Address.new
      
      JSON.load(string).each do |var, val|
        
        if ( var.include? s_prefix )
          
            var = "@" + var[s_prefix.size+1..-1]
            
            if( var == "@shipping_address" )
                  
                self.instance_variable_set( "@shipping_address" , o_addr.build_from_json( val.to_json ) )
               
            else            
              
              self.instance_variable_set( var, val )
              
            end

        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
  end  
end
