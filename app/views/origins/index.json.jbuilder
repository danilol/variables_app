json.array!(@origins) do |origin|
  json.extract! origin, :id, :file_name, :file_description, :created_in_sprint, :updated_in_sprint, :abbreviation, :base_type, :book_mainframe, :periodicity, :periodicity_details, :data_retention_type, :extractor_file_type, :room_1_notes, :mnemonic, :cd5_portal_origin_code, :cd5_portal_origin_name, :cd5_portal_destination_code, :cd5_portal_destination_name, :hive_table_name, :mainframe_storage_type, :room_2_notes
  json.url origin_url(origin, format: :json)
end
