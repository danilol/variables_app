module Constants

  #geral
  STATUS = { SALA1: "sala1", SALA2: "sala2", PRODUCAO: "produção" }
  YES_NO = [ ["Sim", true], ["Não", false] ]

  #Origin
  BASE_TYPE              = ["Arquivo Mainframe", "Tabela Mainframe", "Base Hadoop", "Outro"]
  PERIODICITY            = ["Diária", "Semanal", "Quinzenal", "Mensal", "Anual", "Exporádica", "Outro"]
  DATA_RETENTION_TYPE    = ["Movimento do dia", "Apenas registros alterados", "Histórica", "Acumulado de um período"]
  EXTRACTOR_FILE_TYPE    = ["Novo", "Alterado"]
  DMT_CLASSIFICATION     = ["Atendido", "Pendente Revisão","Não atendido"]
  MAINFRAME_STORAGE_TYPE = ["Disco", "Fita"]

  #OriginField
  DATA_TYPES             = ["Alfanumérico", "Numérico", "Compactado", "Data", "Numérico com vírgula", "Compactado com Vírgula", "Binário Mainframe"]
  FMBASE_FORMAT_TYPE     = ["AN", "ZD", "PD", "BI"]
  GENERIC_DATA_TYPE      = ["texto", "numero", "data"]
  CD5_ORIGIN_FORMAT      = ["1", "2", "4", "2", "4", "6", "3"]
  CD5_ORIGIN_FORMAT_DESC = ["character", "numeric", "Data"]

  #Variable
  DATA_TYPE              = ["Qtd", "Data", "Valor", "Indicador", "Nome", "Código", "Porcentagem", "Número"]
  SAS_UPDATE_PERIODICITY = ["diária", "semanal", "quinzenal", "mensal", "anual", "exporádica", "outro"]
  DOMAIN_TYPE            = ["interno", "externo", "fixo" ]
  SAS_DATA_MODEL_STATUS  = ["Ok", "Pendente"]
  DRS_VARIABLE_STATUS    = ["Ok", "Pendente"]
  VARIABLE_TYPE          = ["calculado", "movimentação direta", "valor padrão"]

  #Campaign
  FACTORY_CRITERION_STATUS = ["Ok", "Pendente"]
  PROCESS_TYPE             = ["Automático", "DBM", "Gestor", "Manual"]

  #Table
  TABLE_TYPE = ["seleção", "colagem", "lookup interna", "lookup externa", "lookup blindagem"]
end
