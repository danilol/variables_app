require 'rails_helper'

describe OriginField do
  let(:profile) { 'room1' }

  before do
    user = FactoryGirl.create(:user, profile: profile)

    subject.current_user_id = user.id
  end

  context '.text_parser' do
    it "should return error when string is empty" do
      org_type="mainframe"
      origin_id=1
      str = ""
      expect(OriginField.text_parser(org_type,str, origin_id, subject.current_user_id)).to eq nil
    end

    it "should return error when string is to small" do
      org_type="mainframe"
      origin_id=1
      str = "123"
      expect(OriginField.text_parser(org_type,str, origin_id, subject.current_user_id)).to eq nil
    end

    it "should return error when string is name invalid" do
      org_type="mainframe"
      origin_id=1
      str = "  3   3 TIP!                                  X(30)     AN      1     30     30"
      expect(OriginField.text_parser(org_type,str, origin_id, subject.current_user_id)).to eq nil
    end

    it "should return error when string is origin_pic invalid" do
      org_type="mainframe"
      origin_id=1
      str = "  3   3 TIPO                                  X 30)     AN      1     30     30"
      expect(OriginField.text_parser(org_type,str, origin_id, subject.current_user_id)).to eq nil
    end

    it "should return error when string is fmbase_format_type invalid" do
      org_type="mainframe"
      origin_id=1
      str = "  3   3 TIPO                                  X(30)     AP      1     30     30"
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

    it "should return error when string is start invalid" do
      org_type="mainframe"
      origin_id=1
      str = "  3   3 TIPO                                  X(30)     AN      1A    30     30"
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end


    it "should return error when string is width invalid" do
      org_type="mainframe"
      origin_id=1
      str = "  3   3 TIPO                                  X(30)     AN      1     30     3A"
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

    it "should return erro when org_type is invalid" do
      org_type="arquivo"
      origin_id=1
      str = "  3   3 TIPO                                  X(30)     AN      1     30     30"
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

    it "should return erro when more fields then expect" do
      org_type="hadoop"
      origin_id=1
      str = '"dat_ref","dat_ref","","<Undefined>","<Undefined>"'
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

    it "should return erro when less fields then expect" do
      org_type="hadoop"
      origin_id=1
      str = '"dat_ref","dat_ref",""'
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

    it "should return erro when invalid first field" do
      org_type="hadoop"
      origin_id=1
      str = '"dat@ref","dat_ref","","<Undefined>"'
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end



    it "should return error inverted type arquivo mainframe -> base hadoop" do
      org_type="mainframe"
      origin_id=1
      str = '"dat_ref","dat_ref","","<Undefined>"'
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

    it "should return error inverted type base hadoop -> arquivo mainframe" do
      org_type="hadoop"
      origin_id=1
      str = "  3   3 TIPO                                  X(30)     AN      1     30     30"
      expect(OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)).to eq nil
    end

   it "should save the object succesfully generic" do
      org_type="hadoop"
      origin_id=1
      str = '"dat_ref","dat_ref","","<Undefined>"'
      origin_field = OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)
      expect(origin_field).to be_kind_of(OriginField)

      expect(origin_field.field_name).to eq "dat_ref"
      expect(origin_field.origin_pic).to eq "X(255)"
      expect(origin_field.data_type).to eq "alfanumerico"
      expect(origin_field.position).to eq 0
      expect(origin_field.width).to eq 0
    end

    it "should save the object succesfully mainframe" do
      org_type="mainframe"
      origin_id=1
      str = "  3   3 TIPO                                  X(30)     AN      1     30     30"
      origin_field = OriginField.text_parser(org_type,str,origin_id, subject.current_user_id)
      expect(origin_field).to be_kind_of(OriginField)

      expect(origin_field.field_name).to eq "TIPO"
      expect(origin_field.origin_pic).to eq "X(30)"
      expect(origin_field.data_type).to eq "alfanumerico"
      expect(origin_field.position).to eq 1
      expect(origin_field.width).to eq 30 
    end
  end

  describe "before_save calculate fields" do

    context "define generic_datyp according the data_type" do
      let(:o) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Alfanumérico") }
      it "equal Alfanumérico" do
        expect(o.generic_datyp).to eq "texto"
      end

      let(:o1) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Numérico") }
      it "equal Numérico" do
        expect(o1.generic_datyp).to eq "numero"
      end

      let(:o2) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Compactado") }
      it "equal Compactado" do
        expect(o2.generic_datyp).to eq "numero"
      end

      let(:o3) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Data") }
      it "equal Data" do
        expect(o3.generic_datyp).to eq "data"
      end

      let(:o4) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Numérico com vírgula") }
      it "equal Numérico com vírgula" do
        expect(o4.generic_datyp).to eq "numero"
      end

      let(:o5) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Compactado com vírgula") }
      it "equal Compactado com vírgula" do
        expect(o5.generic_datyp).to eq "numero"
      end

      let(:o6) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Binário Mainframe") }
      it "equal Binário Mainframe" do
        expect(o6.generic_datyp).to eq "numero"
      end
    end

    context "define field_fmbase_format_datyp according the data_type" do

      let(:o) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Alfanumérico") }
      it "equal Alfanumérico" do
        expect(o.fmbase_format_datyp).to eq "AN"
      end

      let(:o1) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Numérico") }
      it "equal Numérico" do
        expect(o1.fmbase_format_datyp).to eq "ZD"
      end

      let(:o2) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Compactado") }
      it "equal Compactado" do
        expect(o2.fmbase_format_datyp).to eq "PD"
      end

      let(:o3) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Data") }
      it "equal Data" do
        expect(o3.fmbase_format_datyp).to eq "ZD"
      end

      let(:o4) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Numérico com vírgula") }
      it "equal Numérico com vírgula" do
        expect(o4.fmbase_format_datyp).to eq "ZD"
      end

      let(:o5) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Compactado com vírgula") }
      it "equal Compactado com vírgula" do
        expect(o5.fmbase_format_datyp).to eq "PD"
      end

      let(:o6) { FactoryGirl.create(:origin_field, cd5_variable_number: 555, data_type: "Binário Mainframe") }
      it "equal Binário Mainframe" do
        expect(o6.fmbase_format_datyp).to eq "BI"
      end
    end
  end

end

