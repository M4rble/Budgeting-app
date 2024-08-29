# server.R

server <- function(input, output, session) {
  # Initialize transactions with an empty data frame or load from .rds
  transactions <- reactiveVal(load_transactions())
  
  # Initialize categories as an empty vector, and populate it later based on transactions
  categories <- reactiveVal(c())
  
  # Update categories based on transactions whenever transactions change
  observe({
    unique_categories <- unique(transactions()$Kategorija)
    categories(unique_categories)
  })
  
  # Update category dropdowns whenever categories change
  observe({
    updateSelectInput(session, "manual_kategorija", choices = categories())
    updateSelectInput(session, "filter_category", choices = categories())
    updateSelectInput(session, "viz_filter_category", choices = categories())
  })
  
  # Load CSV and process it
  observeEvent(input$file_upload, {
    req(input$file_upload)
    file <- input$file_upload$datapath
    
    tryCatch({
      new_data <- read_and_clean_csv(file)
      transactions(rbind(new_data, transactions()))
      save_transactions(transactions())
    }, error = function(e) {
      showModal(modalDialog(
        title = "Napaka pri nalaganju datoteke",
        "Prišlo je do napake pri nalaganju datoteke. Preverite, če je datoteka pravilno oblikovana.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
  })
  
  # Add manual transaction
  observeEvent(input$add_manual, {
    new_transaction <- data.frame(
      Opis = input$manual_opis,
      Kategorija = input$manual_kategorija,
      Znesek = input$manual_znesek,
      Valuta = input$manual_valuta,
      `Datum plačila` = input$manual_datum,
      Namen = input$manual_namen,
      stringsAsFactors = FALSE
    )
    
    # Ensure the new transaction has the same column names and order as the existing transactions
    colnames(new_transaction) <- colnames(transactions())
    
    # Bind the new transaction to the existing transactions
    transactions(rbind(transactions(), new_transaction))
    
    # Save the updated transactions to file
    save_transactions(transactions())
  })
  
  # Clear all transactions
  observeEvent(input$clear_data, {
    transactions(data.frame(Opis = character(), Kategorija = character(), Znesek = numeric(), 
                            Valuta = character(), `Datum plačila` = as.Date(character()), 
                            Namen = character(), stringsAsFactors = FALSE))
    save_transactions(transactions())
  })
  
  # Render transactions table
  output$transaction_table <- renderDataTable({
    data <- transactions()
    
    
    datatable(
      data,
      rownames = FALSE,
      options = list(
        order = list(list(4, 'desc')), # Sorting by date
        pageLength = 10,  # Number of rows per page
        dom = 'ltip',     # Table controls (length menu, table, info, pagination)
        columnDefs = list(
          list(
            targets = 0, # Adjust the target index to match your columns
            width = '200px'  # Example: set width for "Opis"
          ),
          list(
            targets = 1, # Adjust the target index to match your columns
            width = '150px'  # Example: set width for "Kategorija"
          ),
          list(
            targets = 2, # Adjust the target index to match your columns
            width = '100px'   # Example: set width for "Znesek"
          ),
          list(
            targets = 3, # Adjust the target index to match your columns
            width = '100px'   # Example: set width for "Valuta"
          ),
          list(
            targets = 4, # Adjust the target index to match your columns
            width = '150px'  # Example: set width for "Datum plačila"
          ),
          list(
            targets = 5, # Adjust the target index to match your columns
            width = '200px'  # Example: set width for "Namen"
          )
        )
      ),
      filter = 'top', # Adds a filter input on top of the table
      escape = FALSE  # Allow HTML tags in the table
    )
  })
  
  # Summary table rendering based on filters
  output$summary_table <- renderDataTable({
    data <- transactions()
    
    # Apply the selected filter based on summary_flow_type
    if (input$summary_flow_type == "inflow") {
      data <- filter(data, Znesek >= 0)
    } else if (input$summary_flow_type == "outflow") {
      data <- filter(data, Znesek < 0)
    }
    
    if (!is.null(input$filter_category)) data <- filter(data, Kategorija %in% input$filter_category)
    data <- filter(data, `Datum plačila` >= input$filter_date[1] & `Datum plačila` <= input$filter_date[2])
    
    summary_data <- data %>%
      group_by(Kategorija) %>%
      summarise(Vsota = sum(Znesek), Število = n())
    
    datatable(summary_data)
  })
  
  # Visualization rendering based on filters
  output$viz_plot <- renderPlotly({
    data <- transactions()
    
    # Apply the selected filter based on viz_flow_type
    if (input$viz_flow_type == "inflow") {
      data <- filter(data, Znesek >= 0)
    } else if (input$viz_flow_type == "outflow") {
      data <- filter(data, Znesek < 0)
    }
    
    if (!is.null(input$viz_filter_category)) data <- filter(data, Kategorija %in% input$viz_filter_category)
    data <- filter(data, `Datum plačila` >= input$viz_filter_date[1] & `Datum plačila` <= input$viz_filter_date[2])
    
    # Generate bar plot of transaction amounts over time, colored by category
    plot_ly(data, x = ~`Datum plačila`, y = ~Znesek, type = 'bar', color = ~Kategorija) %>%
      layout(
        title = "Transaction Amounts Over Time",
        xaxis = list(title = "Date"),
        yaxis = list(title = "Amount (Znesek)"),
        barmode = 'stack'  # Optional: stack bars by category
      )
  })
  
  # Manage categories: Add new category
  observeEvent(input$add_category, {
    categories(update_categories(categories(), input$new_category))
  })
  
  # Manage categories: Delete selected category
  observeEvent(input$delete_category, {
    selected_category <- input$category_table_rows_selected
    if (length(selected_category) > 0) {
      categories(categories()[-selected_category])
    }
  })
  
  # Render category table
  output$category_table <- renderDataTable({
    datatable(data.frame(Kategorija = categories()), selection = 'single')
  })
}
