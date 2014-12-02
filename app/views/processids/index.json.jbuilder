json.array!(@processids) do |processid|
  json.extract! processid, :id, :process_number, :mnemonic, :routine_name, :var_table_name, :conference_rule, :acceptance_percent, :keep_previous_work, :counting_rule, :notes
  json.url processid_url(processid, format: :json)
end