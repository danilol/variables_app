require 'rails_helper'

RSpec.describe OriginsController, type: :controller do
  before { session[:user_id] = current_user_id }

  let(:current_user_id)  { User.create(user_attributes).id }
  let(:valid_attributes) { FactoryGirl.attributes_for(:origin, current_user_id: current_user_id) }
  let(:user_attributes)  { FactoryGirl.attributes_for(:user) }
  let(:valid_session)    { {} }

  describe "GET index" do
    let(:origin) { Origin.create(valid_attributes) }

    it "assigns all origins as @origins" do
      get :index, {}, valid_session
      expect(assigns(:origins)).to eq([origin])
    end
  end

  describe "GET search" do
    before do
      @origin1 = FactoryGirl.create(:origin, file_name: "name01", current_user_id: current_user_id, status: Constants::STATUS[:SALA1])
      @origin2 = FactoryGirl.create(:origin, file_name: "name02", current_user_id: current_user_id, status: Constants::STATUS[:SALA2])
      @origin3 = FactoryGirl.create(:origin, file_name: "name3",  current_user_id: current_user_id, status: Constants::STATUS[:PRODUCAO])
      @origin4 = FactoryGirl.create(:origin, file_name: "name4",  current_user_id: current_user_id, status: Constants::STATUS[:SALA1])
    end

    context "with invalid params" do
      context "when no params is sent" do
        it 'returns all records' do
          post :search, valid_session
          expect(assigns(:origins)).to eq([@origin1, @origin2, @origin3, @origin4])
          expect(response).to render_template("index")
        end
      end

      context "when params is blank" do
        it 'returns all records' do
          post :search, { text_param: "", status_param: "" }, valid_session
          expect(assigns(:origins)).to eq([@origin1, @origin2, @origin3, @origin4])
          expect(response).to render_template("index")
        end
      end
    end

    context "with valid params" do
      subject { post :search, { text_param: file, status_param: status }, valid_session }

      context "with only text param" do
        context "with no existent name" do
          let(:file)   { "invalid" }
          let(:status) { "" }

          it 'returns no records' do
            subject
            expect(assigns(:origins)).to eq([])
          end
        end

        context "with part of existent name" do
          let(:file)   { 'name0' }
          let(:status) { "" }

          it 'returns filtered records' do
            subject
            expect(assigns(:origins)).to eq([@origin1, @origin2])
          end
        end

        context "with exactly the same name" do
          let(:file)   { 'name3' }
          let(:status) { "" }

          it 'returns filtered records' do
            subject
            expect(assigns(:origins)).to eq([@origin3])
          end
        end
      end

      context "with only status param" do
        let(:file)   { '' }
        let(:status) { "sala1" }

        it 'returns filtered records' do
          subject
          expect(assigns(:origins)).to eq([@origin1, @origin4])
        end
      end

      context "with both params" do
        let(:file)   { 'name0' }
        let(:status) { "sala1" }

        it 'returns filtered records' do
          subject
          expect(assigns(:origins)).to eq([@origin1])
          expect(response).to render_template("index")
        end
      end
    end
  end

  describe "GET show" do
    let(:origin) { Origin.create(valid_attributes) }

    it "assigns the requested origin as @origin" do
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
    let(:origin) { Origin.create(valid_attributes) }

    it "assigns the requested origin as @origin" do
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
    let(:new_attributes) { FactoryGirl.attributes_for(:origin, file_name: 'teste2', current_user_id: current_user_id) }

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

  describe "POST create origin field" do
    let(:valid_origin_field_attributes) { FactoryGirl.attributes_for(:origin_field, origin_id: @origin.id, current_user_id: current_user_id) }

    before { @origin  = Origin.create! valid_attributes }

    context "with valid params" do
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

  describe "GET origin field" do
    before do
      @origin = Origin.create! valid_attributes
      @origin_field = OriginField.create! valid_origin_field_attributes
    end

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
        :origin_id => @origin.id,
        :current_user_id => current_user_id,
        :created_at => 'teste',
        :updated_at => 'teste'}
    }

    it "to update" do
      get :get_origin_field_to_update, {id: @origin_field.id}, valid_session

      expect(response).to render_template("show")
    end
  end

  describe "DELETE origin field" do
    let(:valid_origin_field_attributes) { FactoryGirl.attributes_for(:origin_field, origin_id: @origin.id, current_user_id: current_user_id) }

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
      let(:file_test) { File.new(Rails.root + 'spec/fixtures/upload_hadoop.txt') }
      let(:file) { ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_hadoop.txt"), content_type: "text/plain") }
      let(:origin) { FactoryGirl.create(:origin, current_user_id: current_user_id) }

      it "assigns new created origin_fields" do
        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  } , file_type: "hadoop" }, valid_session
        }.to change(OriginField, :count).by(8)
      end
    end

    context "with invalid file type and valid file" do
      it "not created any origin_fields" do
        origin = FactoryGirl.create(:origin, current_user_id: current_user_id)

        file_test = File.new(Rails.root + 'spec/fixtures/upload_hadoop.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_hadoop.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  }, file_type: "invalid" }, valid_session
        }.to change(OriginField, :count).by(0)
      end
    end
  end

  describe "POST create origin field upload mainframe file" do
    context "with valid file type and valid file" do
      it "assigns new created origin_fields" do
        origin = FactoryGirl.create(:origin, current_user_id: current_user_id)

        file_test = File.new(Rails.root + 'spec/fixtures/upload_mainframe.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_mainframe.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  } , file_type: "mainframe" }, valid_session
        }.to change(OriginField, :count).by(40)
      end
    end

    context "with invalid file type and valid file" do
      let(:origin) { FactoryGirl.create(:origin, current_user_id: current_user_id) }

      it "not created any origin_fields" do
        file_test = File.new(Rails.root + 'spec/fixtures/upload_mainframe.txt')
        file = ActionDispatch::Http::UploadedFile.new(tempfile: file_test, filename: File.basename("spec/fixtures/upload_mainframe.txt"), content_type: "text/plain")

        expect {
          post :create_origin_field_upload, { origin_field: { origin_id: origin.id, datafile: file  } , file_type: "invalid" }, valid_session
        }.to change(OriginField, :count).by(0)

      end
    end
  end

  describe "GET name search" do
    before do
      @origin = FactoryGirl.create(:origin, current_user_id: current_user_id )
      FactoryGirl.create(:origin_field, id: 1, origin_id: @origin.id, field_name: "MyString1", current_user_id: current_user_id)
      FactoryGirl.create(:origin_field, id: 2, origin_id: @origin.id, field_name: "MyString2", current_user_id: current_user_id)
    end
    context "with valid params" do
      context "with params" do
        it "returns successfully" do
          get :name_search, {:term => 'MyString1'}, valid_session
          expect(response).to be_success
        end

        it "returns 2 items" do
          get :name_search, {:term => 'MyString'}, valid_session
          expect(JSON.parse(response.body).length).to eq(2)
        end
      end

      context "without params" do
        it "returns successfully" do
          get :name_search, valid_session
          expect(response).to be_success
        end

        it "returns 2 items" do
          get :name_search, valid_session
          expect(JSON.parse(response.body).length).to eq(2)
        end
      end
    end

    context "with invalid params" do
      context "with params" do
        it "does not return" do
          get :name_search, {:term => 'DataNotFound'}, valid_session
          expect(response).to be_success
        end
        it "returns 0 items" do
          get :name_search, {:term => 'DataNotFound'}, valid_session
          expect(JSON.parse(response.body).length).to eq(0)
        end
      end
    end
  end

end
