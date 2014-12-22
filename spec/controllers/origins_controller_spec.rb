require 'rails_helper'

RSpec.describe OriginsController, type: :controller do

  before do
    session[:user_id] = User.create(user_attributes)
  end

  # This should return the minimal set of attributes required to create a valid
  # Origin. As you add validations to Origin, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)                { FactoryGirl.attributes_for(:origin) }
  let(:user_attributes)                 { FactoryGirl.attributes_for(:user) }
  let(:valid_session)                   { {} }

  describe "GET show" do
    it "assigns the requested origin as @origin" do
      origin = Origin.create(valid_attributes)

      get :show, { id: origin.to_param }, valid_session

      expect(assigns(:origin)).to eq(origin)
    end
  end

  describe "GET new" do
    it "assigns a new origin as @origin" do
      get :new, {}, valid_session

      expect(assigns(:origin)).to be_a_new(Origin)
    end
  end

  describe "GET edit" do
    it "assigns the requested origin as @origin" do
      origin = Origin.create(valid_attributes)

      get :edit, { id: origin.to_param }, valid_session

      expect(assigns(:origin)).to eq(origin)
    end
  end

  describe "POST create" do
    it "creates a new Origin" do
      expect { post :create, { origin: valid_attributes}, valid_session }.to change(Origin, :count).by(1)
    end

    it "assigns a newly created origin as @origin" do
      post :create, { origin: valid_attributes }, valid_session

      expect(assigns(:origin)).to be_a(Origin)
      expect(assigns(:origin)).to be_persisted
      expect(assigns(:origin).status).to eq 'sala1'
    end

    it "redirects to the created origin" do
      post :create, { origin: valid_attributes }, valid_session

      expect(response).to redirect_to(Origin.last)
    end
  end

  describe "PUT update" do
    let(:origin) { Origin.create(valid_attributes) }
    let(:new_attributes) { FactoryGirl.attributes_for(:origin, file_name: 'teste2') }

    it "updates the requested origin" do
      put :update, { id: origin.to_param, origin: new_attributes }, valid_session
      origin.reload
      expect(origin.file_name).to eq 'teste2'
    end

    it "assigns the requested origin as @origin" do
      put :update, { id: origin.to_param, origin: valid_attributes }, valid_session
      expect(assigns(:origin)).to eq(origin)
      expect(assigns(:origin).status).to eq 'sala1'
    end

    it "assigns the requested origin as @origin and changes status" do
      put :update, { id: origin.to_param, origin: valid_attributes, update_status: "sala2" }, valid_session
      expect(assigns(:origin)).to eq(origin)
      expect(assigns(:origin).status).to eq 'sala2'
    end

    it "redirects to the origin" do
      put :update, { id: origin.to_param, origin: valid_attributes }, valid_session
      expect(response).to redirect_to(origin_path(origin))
    end
  end

  let(:valid_origin_field_attributes) { FactoryGirl.attributes_for(:origin, origin_id: @origin.id) }

  describe "POST create origin field" do
    before do
      @origin  = Origin.create! valid_attributes
    end

    describe "with valid params" do
      it "creates or updates an OriginField" do
        expect {
          post :create_or_update_origin_field,
            {:origin_field => valid_origin_field_attributes.merge(:origin_id => @origin.id) },
            valid_session
        }.to change(OriginField, :count).by(1)
      end

      it "assigns a newly created origin_field as @origin_field" do
        post :create_or_update_origin_field, {:origin_field => valid_origin_field_attributes}, valid_session

        expect(assigns(:origin_field)).to be_a(OriginField)
        expect(assigns(:origin_field)).to be_persisted
      end

      it "redirects to the created origin_field" do
        post :create_or_update_origin_field, {:origin_field => valid_origin_field_attributes}, valid_session

        expect(response).to redirect_to(@origin)
      end
    end
  end

  let(:valid_origin_field_attributes)   { FactoryGirl.attributes_for(:origin_field) }

  describe "GET origin field" do
    let(:valid_origin_field_attributes) {
      valid_origin_field_attributes = {
        :field_name => 'teste',
        :origin_pic => 'teste',
        :data_type => 'teste',
        :decimal => 'teste',
        :mask => 'teste',
        :position => 'teste',
        :width => 'teste',
        :is_key => 'teste',
        :will_use => 'teste',
        :has_signal => 'teste',
        :room_1_notes => 'teste',
        :cd5_variable_number => 'teste',
        :cd5_output_order => 'teste',
        :room_2_notes => 'teste',
        :domain => 'teste',
        :dmt_notes => 'teste',
        :fmbase_format_datyp => 'teste',
        :generic_datyp => 'teste',
        :cd5_origin_frmt_datyp => 'teste',
        :cd5_frmt_origin_desc_datyp => 'teste',
        :default_value_datyp => 'teste',
        :origin_id => 1,
        :current_user_id => 1,
        :created_at => 'teste',
        :updated_at => 'teste'}
    }

  describe "GET origin field" do
    before do
      @origin = Origin.create! valid_attributes
      @origin_field = OriginField.create! valid_origin_field_attributes
    end

    it "to update" do
      get :get_origin_field_to_update, {:format => @origin_field.id}, valid_session

      expect(response).to render_template("show")
    end
  end

  describe "DELETE origin field" do
    before do
      @origin = Origin.create! valid_attributes
      @origin_field = OriginField.create! valid_origin_field_attributes
    end
    it "to destroy" do
      expect{
        delete :destroy_origin_field, {:format => @origin_field.id}, valid_session
        }.to change(OriginField, :count).by(-1)
    end
  end

  describe "POST create origin field upload hadoop file" do
    context "with valid file type and valid file" do
      it "assigns new created origin_fields" do
        origin = FactoryGirl.create(:origin)

        file_test = File.new(Rails.root + 'spec/fixtures/upload_hadoop.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_hadoop.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  } , file_type: "hadoop" }, valid_session
        }.to change(OriginField, :count).by(8)
      end
    end

    context "with invalid file type and valid file" do
      it "not created any origin_fields" do
        #require "pry";binding.pry;
        #session[:user_id] = User.create! user_attributes
        origin = FactoryGirl.create(:origin)

        file_test = File.new(Rails.root + 'spec/fixtures/upload_hadoop.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_hadoop.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  }, file_type: "invalid" }, valid_session
        }.to change(OriginField, :count).by(0)

        #expect(response).to redirect_to(origin_field)
      end
    end
  end

  describe "POST create origin field upload mainframe file" do
    context "with valid file type and valid file" do
      it "assigns new created origin_fields" do
        #require "pry";binding.pry;
        #session[:user_id] = User.create! user_attributes
        origin = FactoryGirl.create(:origin)

        file_test = File.new(Rails.root + 'spec/fixtures/upload_mainframe.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_mainframe.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  } , file_type: "mainframe" }, valid_session
        }.to change(OriginField, :count).by(40)

        #expect(response).to redirect_to(origin_field)
      end
    end

    context "with invalid file type and valid file" do
      it "not created any origin_fields" do
        origin = FactoryGirl.create(:origin)

        file_test = File.new(Rails.root + 'spec/fixtures/upload_mainframe.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_mainframe.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  } , file_type: "invalid" }, valid_session
        }.to change(OriginField, :count).by(0)

      end
    end
  end
end

end
