RSpec.configure do |config|  
  config.before(:each) do
    # stub mongo calls
    @collection_stub_instance = instance_double(Mongo::Collection)
    allow(@collection_stub_instance).to receive(:find_one_and_update).with(any_args)
    allow(@collection_stub_instance).to receive(:find).with(any_args)

    @mongo_client_instance = instance_double(Mongo::Client)
    allow(@mongo_client_instance).to receive_message_chain(:database, :[]).and_return(@collection_stub_instance)
    allow(@mongo_client_instance).to receive(:close).with(no_args)

    @mongo_client_class = class_double(Mongo::Client).as_stubbed_const
    allow(@mongo_client_class).to receive(:new).and_return(@mongo_client_instance)
  end
end