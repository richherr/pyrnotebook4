if (isTRUE(getOption("radiant.from.package"))) {
  library(radiant)
  options(radiant.report=TRUE)
}

shinyServer(function(input, output, session) {

  summary.correlation <- radiant.basics:::summary.correlation

  enc <- getOption("radiant.encoding")

  ## source shared functions
  source(file.path(getOption("radiant.path.data"), "app/init.R"), encoding = enc, local = TRUE)
  source(file.path(getOption("radiant.path.data"), "app/radiant.R"), encoding = enc, local = TRUE)

  ## source data & app tools from radiant.data
  for (file in list.files(
    c(
      file.path(getOption("radiant.path.data"), "app/tools/app"),
      file.path(getOption("radiant.path.data"), "app/tools/data")
    ),
    pattern = "\\.(r|R)$",
    full.names = TRUE)) {
    source(file, encoding = enc, local = TRUE)
  }

  ## list of radiant menu's to include
  rmenus <- c("radiant.data", "radiant.design", "radiant.basics", "radiant.model", "radiant.multivariate")

  ## packages to use for example data
  options(radiant.example.data = rmenus)

  for (i in rmenus[-1]) {
    ## 'sourcing' radiant's package functions in the server.R environment
    if (!isTRUE(getOption("radiant.from.package"))) {
      eval(parse(text = paste0("radiant.data::copy_all(", i, ")")))
      cat(paste0("\nGetting ", i, " from source ...\n"))
    }

    ## help ui
    ipath <- paste0(strsplit(i, "\\.")[[1]], collapse = ".path.")
    source(file.path(getOption(ipath), "app/help.R"), encoding = enc, local = TRUE)

    ## source analysis tools for each app
    for (file in list.files(file.path(getOption(ipath), "app/tools/analysis"), pattern = "\\.(r|R)$", full.names = TRUE))
      source(file, encoding = enc, local = TRUE)
  }

  ## ui creation functions
  source(file.path(getOption("radiant.path.model"), "app/radiant.R"), encoding = enc, local = TRUE)

  ## help ui
  output$help_ui <- renderUI({
    sidebarLayout(
      sidebarPanel(
        help_data_panel,
        help_design_panel,
        help_basics_panel,
        help_model_panel,
        help_multivariate_panel,
        uiOutput("help_text"),
        width = 3
      ),
      mainPanel(
        HTML(paste0("<h2>Select help files to show and search</h2><hr>")),
        htmlOutput("help_data"),
        htmlOutput("help_design"),
        htmlOutput("help_basics"),
        htmlOutput("help_model"),
        htmlOutput("help_multivariate")
      )
    )
  })

  ## save state on refresh or browser close
  saveStateOnRefresh(session)
})
