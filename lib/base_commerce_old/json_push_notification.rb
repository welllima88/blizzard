# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require_relative 'push_notification.rb'

class JSONPushNotification < PushNotification
  def initialize
    super.instance_variable_set("@type", PushNotification.xs_pn_type_json) 
  end
  
  attr_accessor :json
  
=begin
  Returns a JSON representation of the JSONPushNotification

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json
      self.instance_variable_get "@json"
  end
  
=begin
  Builds a PushNotification object based off of the JSON input.
  The caller is set to the new PN object, nothing is returned

  @param vo_json   the json
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(vo_json) 
      self.instance_variable_set("@json", vo_json)
  end
  
end
