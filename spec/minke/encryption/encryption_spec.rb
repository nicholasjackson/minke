require 'spec_helper'

describe Minke::Encryption::Encryption do

  let(:encrypt) { Minke::Encryption::Encryption.new File.expand_path("../../../data/id_rsa", __FILE__) }

  it 'succesfully encrypts a string' do
    encrypted = encrypt.encrypt_string("tester")

    expect(encrypt.decrypt_string(encrypted)).to eq("tester")
  end

  it 'succesfully returns a fingerprint' do
    expect(encrypt.fingerprint).to eq("90:5d:ee:d4:8f:cf:c6:a7:05:53:07:79:a2:01:51:0a")
  end
end
