require 'spec_helper'

describe Minke::Encryption::KeyLocator do

  let(:locator) { Minke::Encryption::KeyLocator.new File.expand_path("../../../data", __FILE__) }

  it 'successfully locates a key' do
    path = locator.locate_key "90:5d:ee:d4:8f:cf:c6:a7:05:53:07:79:a2:01:51:0a"

    expect(path).to include("id_rsa")
  end


end
