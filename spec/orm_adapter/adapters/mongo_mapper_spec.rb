require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(MongoMapper) || !(Mongo::Connection.new.db('orm_adapter_spec') rescue nil)
  puts "** require 'mongo_mapper' start mongod to run the specs in #{__FILE__}"
else  
  
  MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
  MongoMapper.database = 'orm_adapter_spec'
  MongoMapper.database.collections.each { |c| c.drop_indexes }
  
  module MongoMapperOrmSpec
    class User
      include MongoMapper::Document
      key :name
      key :rating
      many :notes, :foreign_key => :owner_id, :class_name => 'MongoMapperOrmSpec::Note'
    end

    class Note
      include MongoMapper::Document
      key :body, :default => "made by orm"
      belongs_to :owner, :class_name => 'MongoMapperOrmSpec::User'
    end
    
    # here be the specs!
    describe MongoMapper::Document::OrmAdapter do
      before do
        User.delete_all
        Note.delete_all
      end
      
      describe "the OrmAdapter class" do
        subject { MongoMapper::Document::OrmAdapter }

        specify "#model_classes should return all document classes" do
          (subject.model_classes & [User, Note]).to_set.should == [User, Note].to_set
        end
      end
    
      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end