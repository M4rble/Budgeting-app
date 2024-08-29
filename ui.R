# ui.R

dashboardPage(
  dashboardHeader(title = "Aplikacija za proračun"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Pregled transakcij", tabName = "overview", icon = icon("table")),
      menuItem("Povzetek", tabName = "summary", icon = icon("chart-bar")),
      menuItem("Vizualizacija", tabName = "visualization", icon = icon("chart-line")),
      menuItem("Upravljanje kategorij", tabName = "manage_categories", icon = icon("tags"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Transaction Overview Tab
      tabItem(tabName = "overview",
              fluidRow(
                box(
                  title = "Nalaganje podatkov", width = 4, solidHeader = TRUE, status = "primary",
                  fileInput("file_upload", "Naloži CSV datoteko", accept = c(".csv")),
                  actionButton("clear_data", "Izbriši vse transakcije", icon = icon("trash"))
                ),
                box(
                  title = "Ročni vnos", width = 4, solidHeader = TRUE, status = "primary",
                  textInput("manual_opis", "Opis"),
                  selectInput("manual_kategorija", "Kategorija", choices = NULL),
                  numericInput("manual_znesek", "Znesek", value = 0, min = 0, step = 0.01),
                  selectInput("manual_valuta", "Valuta", choices = c("EUR", "USD", "GBP"), selected = "EUR"),
                  dateInput("manual_datum", "Datum plačila", value = Sys.Date()),
                  textInput("manual_namen", "Namen"),
                  actionButton("add_manual", "Dodaj transakcijo", icon = icon("plus"))
                )
              ),
              fluidRow(
                box(
                  title = "Seznam transakcij", width = 12, solidHeader = TRUE, status = "primary",
                  dataTableOutput("transaction_table")
                )
              )
      ),
      
      # Summary Tab
      tabItem(tabName = "summary",
              fluidRow(
                box(
                  title = "Filtri", width = 4, solidHeader = TRUE, status = "primary",
                  radioButtons(
                    inputId = "summary_flow_type",
                    label = "Izberi vrsto transakcije", 
                    choices = list("Prikaz prilivov" = "inflow", "Prikaz odlivov" = "outflow"),
                    selected = "outflow"
                  ),
                  selectInput("filter_category", "Izberi kategorijo", choices = NULL, multiple = TRUE),
                  dateRangeInput("filter_date", "Izberi časovno obdobje", start = Sys.Date() - 30, end = Sys.Date())
                ),
                box(
                  title = "Povzetek", width = 8, solidHeader = TRUE, status = "primary",
                  dataTableOutput("summary_table")
                )
              )
      ),
      
      # Visualization Tab
      tabItem(tabName = "visualization",
              fluidRow(
                box(
                  title = "Filtri", width = 4, solidHeader = TRUE, status = "primary",
                  radioButtons(
                    inputId = "viz_flow_type",
                    label = "Izberi vrsto transakcije", 
                    choices = list("Prikaz prilivov" = "inflow", "Prikaz odlivov" = "outflow"),
                    selected = "outflow"
                  ),
                  selectInput("viz_filter_category", "Izberi kategorijo", choices = NULL, multiple = TRUE),
                  dateRangeInput("viz_filter_date", "Izberi časovno obdobje", start = Sys.Date() - 30, end = Sys.Date())
                ),
                box(
                  title = "Vizualizacija", width = 8, solidHeader = TRUE, status = "primary",
                  plotlyOutput("viz_plot")
                )
              )
      ),
      
      # Manage Categories Tab
      tabItem(tabName = "manage_categories",
              fluidRow(
                box(
                  title = "Upravljanje kategorij", width = 6, solidHeader = TRUE, status = "primary",
                  textInput("new_category", "Dodaj novo kategorijo"),
                  actionButton("add_category", "Dodaj kategorijo", icon = icon("plus")),
                  dataTableOutput("category_table"),
                  actionButton("delete_category", "Izbriši izbrano kategorijo", icon = icon("minus"))
                )
              )
      )
    )
  )
)
