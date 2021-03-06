class Generator

  def self.export_script_by_sprint(sprint, script_name)
    array_script = generate_script_by_sprint(sprint, script_name)
    output = "Nome do Script: #{script_name}\nResultado do Script : \n"
    output << "=========================================================================\n"

    array_script.each do |line|
      output << line + "\n"
      output << "----------------------------------------------------------------------\n"
    end

    output << "=========================================================================\n"
    output << "Fim do script\n"
    return output
  end

  #================================== metodos de processamento =========================================
  def self.generate_script_by_sprint(sprint, script_name)
    dictionary   = Support.make_dictionary

    entity_master_br  = Support::HASH_SCRIPTS[script_name]["entity_master_br"]
    ind_group_related = Support::HASH_SCRIPTS[script_name]["ind_group_related"]
    script            = Support::HASH_SCRIPTS[script_name]["script"]
    condition         = Support::HASH_SCRIPTS[script_name]["condition"]

    ind_valid_relationship = 'S'
    ind_entity_reference   = 'N'
    ind_group_funcion      = 'S'

    list_entity    = get_entities_list(script)
    list_condition = get_entities_list(condition) if condition

    invert_entity_dictionary = Hash.new

    dictionary.keys.each do |key|
      invert_entity_dictionary[dictionary[key][:name_entity]] = key
    end

    list_entity_translated    = translate_list(list_entity,    dictionary)
    list_condition_translated = translate_list(list_condition, dictionary) if condition

    list_entity_master = []
    list_entity_reference_name =[]

    list_entity_translated.each_key do |entity_name_eng|
      if dictionary[entity_master_br][:name_entity] == entity_name_eng
        if condition
          list_entity_master = get_entities_by_sprint(sprint, entity_name_eng, list_condition_translated[entity_name_eng])
        else
          list_entity_master = get_entities_by_sprint(sprint, entity_name_eng, nil)
        end
      else
        list_entity_reference_name = list_entity_reference_name + [entity_name_eng]
      end
    end

    ind_entity_reference = 'S' if list_entity_reference_name.size > 0

    hash_replace_master = {}
    return_value = []

    list_entity_master.each do |entity_master|
      hash_replace_master = {}

      list_entity[entity_master_br].each do |attr_master_Br|
        key_replace_master   = "<#{entity_master_br}.[#{attr_master_Br}]>"
        ent_Eng              = dictionary[entity_master_br][:name_entity]
        attr_master_eng      = dictionary[entity_master_br][:translated_attribute][attr_master_Br]

        if attr_master_Br.include? "@"
          value_replace_master = value_by_function(entity_master,attr_master_Br)
        else
          value_replace_master = entity_master[attr_master_eng]
        end

        hash_replace_master[key_replace_master] = value_replace_master
      end

      if ind_entity_reference == 'N'
        script_replace = script.gsub /\<[A-Za-z\ ]+\.\[.+?\]\>/ do
          |match| hash_replace_master[match.to_s]
        end

       return_value << script_replace
      else
        hash_repalce_related = {}

        list_entity_reference_name.each do |entity_reference_name_eng|
          array_entities_related = []

          if condition
            array_entities_related = get_entities_related(entity_master, entity_reference_name_eng, list_condition_translated[entity_reference_name_eng])
          else
            array_entities_related = get_entities_related(entity_master, entity_reference_name_eng)
          end

          entity_reference_name_br = invert_entity_dictionary[entity_reference_name_eng]

          list_entity[entity_reference_name_br].each do |attr_reference_Br|

            key_replace_reference = "<#{entity_reference_name_br}.[#{attr_reference_Br}]>"
            attr_reference_eng    = dictionary[entity_reference_name_br][:translated_attribute][attr_reference_Br]

            if array_entities_related.nil?
              ind_valid_relationship = "N"

            elsif ind_group_related && attr_reference_Br.include?("@")
              value_replace_reference = value_by_function(array_entities_related,attr_reference_Br)

            elsif ind_group_related && ( ! attr_reference_Br.include?("@") )
              ind_group_funcion = 'N'

            elsif ( ! ind_group_related ) && ( attr_reference_Br.include? ("@") )
              value_replace_reference = value_by_function(array_entities_related,attr_reference_Br)
            else
              value_replace_reference = array_entities_related[0][attr_reference_eng]
            end

            hash_repalce_related[key_replace_reference] = value_replace_reference

          end
        end
        hash_repalce_all = hash_replace_master.merge hash_repalce_related

        script_replace = script.gsub /\<[A-Za-z\ ]+\.\[.+?\]\>/ do |match|
          hash_repalce_all[match.to_s]
        end

        return_value = return_value + [script_replace]
      end
    end

    if return_value.size == 0 || ind_valid_relationship == "N" || ind_group_funcion == 'N'
      return_value = nil
    end

    return_value
  end

  def self.get_entities_list(script = nil)
    return {} unless script

    script_list = script.scan(Support::REGEX)

    list_ent = Hash.new
    script_list.each do |item|
      if list_ent.has_key?(item[0])
        list_ent[item[0]] << item[1]
        list_ent[item[0]].uniq!
      else
        list_ent[item[0]] = [item[1]]
      end
    end

    list_ent
  end

  def self.translate_list(list = nil, hash_transl)
    test_hash_pass='S'
    test_entity='S'
    test_attr='S'

    lista_ent = Hash.new

    if list && (list.instance_of? Hash) && list.size > 0
      list.each_key do |ent_Br|
        if list[ent_Br] && (list[ent_Br].instance_of? Array) && list[ent_Br].size > 0 && hash_transl.has_key?(ent_Br)
          ent_Eng = hash_transl[ent_Br][:name_entity]
          lista_ent[ent_Eng] = []
          list[ent_Br].each do |attr_Br|
            unless hash_transl[ent_Br][:translated_attribute].has_key?(attr_Br.split(/\=/).first) ||
              attr_Br.include?("@")
              test_attr = 'N'
            else
              attr_Eng = hash_transl[ent_Br][:translated_attribute][attr_Br.split(/\=/).first]
              if attr_Br.include? "="
                lista_ent[ent_Eng] << attr_Eng + "=" + attr_Br.split(/\=/).last
              elsif attr_Br.include? "@"
                lista_ent[ent_Eng] << attr_Br
              else
                lista_ent[ent_Eng] << attr_Eng
              end
            end
          end
        else
          test_entity = 'N'
        end
      end
    else
      test_hash_pass='N'
      test_attr = 'S'
    end

    if test_hash_pass == 'S' && test_entity == 'S' && test_attr == 'S'
      return_value = lista_ent
    else
      return_value = nil
    end

    return_value
  end

  def self.get_entities_by_sprint(sprint, entity, condition)
    unless ( ! (sprint.nil?) ) && ( ! (entity.nil?) ) && (sprint.instance_of?(Fixnum)) && (entity.instance_of?(String)) && ! (entity.empty?) && (sprint > 0 )
      value = nil
    else
      case entity
      when "Campaign"
        value = get_campaign_by_sprint(sprint,condition)
      when "Table"
        value = get_table_by_sprint(sprint,condition)
      when "Origin"
        value = get_origin_by_sprint(sprint,condition)
      when "OriginField"
        value = get_origin_field_by_sprint(sprint,condition)
      when "Processid"
        value = get_Processid_by_sprint(sprint,condition)
      when "Variable"
        value = get_variable_by_sprint(sprint,condition)
      else
        value = nil
      end
    end

    value
  end

  def self.get_entities_related(entity_ref, name_entity_to_find, condition = nil)
    list_entity_valid = { "Variable"    => "variables",
                          "Origin"      => "origin",
                          "OriginField" => "origin_fields",
                          "Campaign"    => "campaigns",
                          "Processid"   => "processids",
                          "Table"       => "tables" }

    ind_valid_parms = 'S'
    ind_valid_relationship = 'S'
    list_relationtship = []

    unless entity_ref != nil && name_entity_to_find != nil &&
      list_entity_valid.has_key?(entity_ref.class.to_s) &&
      list_entity_valid.has_key?(name_entity_to_find)

      ind_valid_parms = 'N'
    else
      entity_ref.class.reflect_on_all_associations(:belongs_to).each do |entity|
        list_relationtship = list_relationtship + [entity.name.to_s]
      end

      entity_ref.class.reflect_on_all_associations(:has_and_belongs_to_many).each do |entity|
        list_relationtship = list_relationtship + [entity.name.to_s]
      end

      entity_ref.class.reflect_on_all_associations(:has_many).each do |entity|
        list_relationtship = list_relationtship + [entity.name.to_s]
      end

      list_relationtship.uniq!

      unless list_relationtship.size > 0 && list_relationtship.include?(list_entity_valid[name_entity_to_find])
        ind_valid_relationship = 'N'
      end
    end

    unless ind_valid_parms == 'S' && ind_valid_relationship == 'S'
      value = nil
    else
      cond = {}
      if condition.nil?
        cond = false
      else
        condition.each do |item|
          words = item.split(/\=/)
          if words[1] =="true"
            words[1] = true
          end
          if words[1] == "false"
            words[1] = false
          end

          cond[words[0]]=words[1]
        end
      end

      case list_entity_valid[name_entity_to_find]
      when "variables"
        value = entity_ref.variables.where(cond).to_a
      when "origin"
        value = [entity_ref.origin]
      when "origin_fields"
        value = entity_ref.origin_fields.where(cond).to_a
      when "campaigns"
        value = entity_ref.campaigns.where(cond).to_a
      when "processids"
        value = entity_ref.processids.where(cond).to_a
      when "tables"
        value = entity_ref.tables.where(cond).to_a
      else
        value = nil
      end

    end

    value
  end

  def self.get_campaign_by_sprint(sprint = nil, condition = nil)
    Campaign.where(updated_in_sprint: sprint).where(condition).to_a
  end

  def self.get_table_by_sprint(sprint = nil, condition = nil)
    Table.where(updated_in_sprint: sprint).where(condition).to_a
  end

  def self.get_origin_by_sprint(sprint = nil, condition = nil)
    Origin.where(updated_in_sprint: sprint).where(condition).to_a
  end

  def self.get_origin_field_by_sprint(sprint = nil, condition = nil)
    OriginField.joins(:origin).where("origins.updated_in_sprint = ?", sprint).where(condition).to_a
  end

  def self.get_originField_by_sprint(sprint,condition)
    return_value = ''

    cond = {}
    if condition.nil?
      cond = false
    else
      condition.each do |item|
        words=item.split(/\=/)
        if words[1] == "true"
          words[1] = true
        end
        if words[1] == "false"
          words[1] = false
        end
        cond[words[0]]=words[1]
      end
    end

    result = []
    Origin.where(updated_in_sprint: sprint).to_a.each do |org|
      result = result + org.origin_fields.where(cond).to_a
    end

    if result.size == 0
      return_value = nil
    else
      return_value = result
    end

    return_value
  end

  def self.get_Processid_by_sprint(sprint,condition)
    return_value = ''

    cond = {}
    if condition.nil?
      cond = false
    else
      condition.each do |item|
        words=item.split(/\=/)
        cond[words[0]]=words[1]
      end
    end

    result = []
    Variable.where(updated_in_sprint: sprint).to_a.each do |pro|
      result = result + pro.processids.where(cond).to_a
    end

    if result.size == 0
      return_value = nil
    else
      return_value = result
    end

    return_value
  end

  def self.get_variable_by_sprint(sprint = nil, condition = nil)
    cond = {}

    Array(condition).each do |item|
      words = item.split(/\=/)
      cond[words[0]] = words[1]
    end

    Variable.where(updated_in_sprint: sprint).where(cond).to_a
  end

  def self.value_by_function(entity,attr_master_Br)
    return_value = ''

    case attr_master_Br
    when "@nome_data_stage_espelho"
      return_value = nome_data_stage(entity, "espelho" )
    when "@nome_data_stage_definitivo"
      return_value = nome_data_stage(entity, "definitivo" )
    when "@periodicidade_origem_mysql"
      return_value = periodicidade(entity,"mysql")
    when "@periodicidade_origem_particao"
      return_value = periodicidade(entity,"particao")
    when "@periodicidade_origem_smap"
      return_value = periodicidade(entity,"smap")
    when "@periodicidade_processo_mysql"
      return_value = periodicidade(entity,"mysql")
    when "@periodicidade_processo_smap"
      return_value = periodicidade(entity,"smap")
    when "@periodicidade_tabela_smap"
      return_value = periodicidade(entity,"smap")
    when "@periodicidade_tabela_mysql"
      return_value = periodicidade(entity,"mysql")
    when "@lista_de_campos"
      return_value = lista_de_campos(entity)
    when "@expressao_regular"
      return_value = expressao_regular(entity)
    when "@tamanho_expandido"
      return_value = tamanho_expandido(entity)
    when "@posicao_saida"
      return_value = posicao_saida(entity)
    when "@chave_hive"
      return_value = chave_hive(entity)
    when "@lista_de_rotinas_sucessoras"
      return_value = lista_de_rotinas_sucessoras(entity)
    when "@campos_modelo"
      return_value = campos_modelo(entity)

    else
      return_value = nil
    end

    return_value

  end


  def self.nome_data_stage(table, type)

    return_value = ''
    result = ''


    unless ( ! table.nil? ) && ( ! table.nil? ) && table.instance_of?(Table) &&
      ( type == "espelho" || type == "definitivo" )
      return_value = nil
    else
      #mirror_table_number
      #mirror_physical_table_name
      number_table = nil
      name_table = nil
      slice_type = nil
      end_type = nil

      if type == "espelho"
        slice_type = "_ESPL_"
        end_type = "_esp"
        number_table = table.mirror_table_number.to_s
        name_table = table.mirror_physical_table_name.to_s
      else
        slice_type = "_"
        end_type = "_def"
        number_table = table.final_table_number.to_s
        name_table = table.final_physical_table_name.to_s
      end


      slice_part = "TBCD5" + number_table + slice_type
      part_table_part =  name_table
      part_table_part.slice!(slice_part)

      return_value = "CD5_" + number_table + "_carga_tabela_" + part_table_part.to_s.downcase + end_type


    end

    return_value
  end

  def self.periodicidade(entity,type)
    return_value = ''

    unless ( ! entity.nil? ) && ( ! type.nil? ) &&
      ( entity.instance_of?(Origin) || entity.instance_of?(Table) || entity.instance_of?(Processid) )&&
      type.instance_of?(String) &&
      (type == "mysql" || type == "particao" || type == "smap")
      return_value = nil

    else
      if entity.instance_of?(Origin)
        if type == "smap"
          return_value = entity.periodicity
        elsif entity.periodicity == "mensal" && type == "mysql"
          return_value = "M"
        elsif entity.periodicity == "mensal" && type == "particao"
          return_value = "anomes"
        elsif type == "particao"
          return_value = "anomesdia"
        else
          return_value = "D"
        end
      else
        priority = {
          "diária" => 1 ,
          "semanal" => 2 ,
          "quinzenal" => 3 ,
          "mensal"  => 4 ,
          "anual" => 5 ,
          "exporádica" => 6 ,
          "outro" => 7
        }

        #p "============="
        unless entity.variables.to_a.size > 0
          result = nil
        else
          result = "outro"
          entity.variables.to_a.each do |variable|

            if priority[result] > priority[variable.sas_update_periodicity]
              #p "trocou"
              result = variable.sas_update_periodicity
            end
          end
        end

        if type == "smap" || entity.variables.to_a.size == 0
          return_value = result
        elsif result == "mensal" && type == "mysql"
          return_value = "M"
        elsif result == "mensal" && type == "particao"
          return_value = "anomes"
        elsif type == "particao"
          return_value = "anomesdia"
        else
          return_value = "D"
        end
      end
    end
    return_value

  end

  def self.lista_de_campos(array_orign_fields)
    return_value = ''
    #p "array_orign_fields #{array_orign_fields}"
    unless ( ! array_orign_fields.nil? ) && array_orign_fields.instance_of?(Array) && array_orign_fields.size > 0   && array_orign_fields[0].instance_of?(OriginField)
      return_value = nil
    else
      #p "array_orign_fields #{array_orign_fields}"
      #p "class = #{array_orign_fields.class}"
      array_orign_fields.each do |origin_field|
        return_value = return_value + origin_field.field_name + " string , \n"
      end

      return_value = return_value + "FILLER string "
    end


    return_value
  end

  def self.lista_de_rotinas_sucessoras(array_variable)
    return_value = ''

    unless ( ! array_variable.nil? ) && array_variable.instance_of?(Array) && array_variable.size > 0   && array_variable[0].instance_of?(Variable)
      return_value = nil
    else
      #p "array_orign_fields #{array_orign_fields}"
      #p "class = #{array_orign_fields.class}"
      return_value = ''
      array_variable.each do |variable|
        variable.tables.where( table_type: "seleção" ).to_a.each do |table|
          return_value = return_value + table.big_data_routine_name + " ;"
        end
      end

      return_value = return_value
    end


    return_value
  end

  def self.tamanho_expandido(origin_field)

    return_value = ''

    unless ( ! origin_field.nil? ) && ( origin_field.instance_of?(OriginField))
      return_value = nil
    else
      if origin_field.fmbase_format_datyp == "AN" || origin_field.fmbase_format_datyp == "BI"
        return_value = origin_field.width.to_s
      else

        vlr_signal = 0
        vlr_comma = 0

        if origin_field.has_signal == true
          vlr_signal = 1
        end

        if origin_field.data_type == "numerico com virgula" || origin_field.data_type == "compactado com virgula"
          vlr_comma = 1
        end
        result = origin_field.width + vlr_comma + vlr_signal

        return_value = result.to_s

      end
    end

    return_value
  end

  def self.expressao_regular(array_orign_fields)
    return_value = ''

    unless array_orign_fields && array_orign_fields.instance_of?(Array) && array_orign_fields.size > 0   && array_orign_fields[0].instance_of?(OriginField)
      return_value = nil
    else
      return_value = ""
      array_orign_fields.each do |origin_field|
        if  origin_field.will_use
          return_value += "(.{0," + tamanho_expandido(origin_field) + "})"
        end
      end

      return_value += "(.{0,1343})"
    end

    return_value
  end

  def self.chave_hive(processid)
    return_value = ''

    if processid && processid.instance_of?(Processid) && processid.variables.size > 0 && processid.variables.to_a[0].tables.where( table_type: "seleção").to_a.size > 0
      return_value = processid.variables.to_a[0].tables.where( table_type: "seleção").to_a[0].key_fields_hive_script.to_s
    else
      return_value = nil
    end

    return_value
  end

  def self.campos_modelo(processid)
    return_value = ''

    if processid  && processid.instance_of?(Processid) && processid.variables.to_a.size > 0
      processid.variables.each do |variable|
        if variable.model_field_name == processid.variables.last.model_field_name
          return_value <<  variable.model_field_name + " string \n"
        else
          return_value << variable.model_field_name + " string , \n"
        end
      end
    else
      return_value = nil
    end

    return_value
  end

  def self.posicao_saida(origin_field)
    return_value = nil

    if ( origin_field) && origin_field.instance_of?(OriginField) && origin_field.will_use
      return_value = 0

      origin_field.origin.origin_fields.where(will_use: true).to_a.each do |org_atu|
        if org_atu.cd5_output_order < origin_field.cd5_output_order
          return_value += tamanho_expandido(org_atu).to_i
        end
      end

      return_value += 1
      return_value = return_value.to_s
    end

    return_value
  end
end
