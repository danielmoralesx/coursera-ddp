library(car)
library(ggplot2)
library(qqplotr)
library(shiny)

shinyServer(function(input, output) {
  
  # Calculates the vector of samples from the mean distribution, which should be
  # asymptotically normal, according to the CLT
  means <- reactive({
    validate(
      need(is.integer(input$sample_size),
           "Please enter an integer as sample size"),
      need(as.integer(input$sample_size) > 0,
           "The sample size should be greater than 0"),
      need(is.integer(input$N_means),
           "Please enter an integer as mean distribution sample size"),
      need(as.integer(input$N_means) > 0,
           "The mean distribution sample size should be greater than 0")
    )
    if (input$dist == "Normal") {
      validate(
        need(is.numeric(input$parameter1),
             "The normal mean parameter should be a number"),
        need(as.numeric(input$parameter2) > 0, 
             paste("The normal standard deviation parameter should be", 
                   "a number greater than 0")
        )
      )
      sapply(1:input$N_means, function(x) 
        mean(rnorm(input$sample_size, 
                   mean = input$parameter1, sd = input$parameter2)))
    } else if (input$dist == "Exponential") {
      validate(
        need(as.numeric(input$parameter1) > 0, 
             "The exponential rate parameter should be a number greater than 0")
      )
      sapply(1:input$N_means, function(x) 
        mean(rexp(input$sample_size, 
                  rate = input$parameter1)))
    } else if (input$dist == "Binomial") {
      validate(
        need(is.integer(input$parameter1),
             "Please enter an integer as binomial size parameter"),
        need(as.numeric(input$parameter1) > 0,
             "The binomial size parameter should be greater than 0"),
        need(
          as.numeric(input$parameter2) > 0 & as.numeric(input$parameter2) < 1, 
          paste("The binomial probability of success parameter should be",
                "a number greater than 0 and less than 1")
        )
      )
      sapply(1:input$N_means, function(x) 
        mean(rbinom(input$sample_size, 
                    size = input$parameter1, prob = input$parameter2)))
    
    } else if (input$dist == "Poisson") {
      validate(
        need(as.numeric(input$parameter1) > 0, 
             "The poisson mean parameter should be a number greater than 0")
      )
      sapply(1:input$N_means, function(x) 
        mean(rpois(input$sample_size, 
                   lambda = input$parameter1)))
    }
  })
  
  # Mean for the CLT normal
  limit_mean <- reactive({
    if      (input$dist == "Normal")      input$parameter1
    else if (input$dist == "Exponential") 1 / input$parameter1
    else if (input$dist == "Binomial")    input$parameter1 * input$parameter2
    else if (input$dist == "Poisson")     input$parameter1
  })
  
  # Standard deviation for the CLT normal
  limit_sd <- reactive({
    if (input$dist == "Normal")      
      input$parameter2 / sqrt(input$sample_size)
    else if (input$dist == "Exponential") 
      sqrt(1 / (input$parameter1 ^ 2 * input$sample_size))
    else if (input$dist == "Binomial")
      sqrt(input$parameter1 * input$parameter2 * (1 - input$parameter2) /
             input$sample_size)
    else if (input$dist == "Poisson")
      sqrt(input$parameter1 / input$sample_size)
  })
  
  # Histogram vs density plot
  output$mean_dist_plot <- renderPlot({
    ggplot(data.frame(hist = means()), environment = environment()) +
      geom_histogram(aes(x = hist, y = ..density..), 
                     fill = "lightblue", bins = 30) +
      geom_function(fun = function(x) dnorm(x, limit_mean(), limit_sd()), 
                    n = 5001) +
      theme_bw() +
      labs(title = paste("Histogram Mean Distribution Samples vs",
                         "Density CLT Limit Distribution"), 
           x = "Mean Distribution", y = "Density")
  })
  
  # QQ-Plot samples from the mean distribution vs CLT asymptotic normal 
  # distribution
  output$qqplot <- renderPlot({
    ggplot(data.frame(sample = means()), aes(sample = sample)) + 
      geom_qq_band(fill = "lightblue", distribution = "norm", 
                   dparams = list(mean = limit_mean(), sd = limit_sd())) + 
      geom_qq(distribution = qnorm, 
              dparams = list(mean = limit_mean(), sd = limit_sd())) + 
      geom_abline(slope = 1, intercept = 0) +
      theme_bw() + 
      labs(
        title = "QQ-Plot: Mean Distribution Samples vs CLT Limit Distribution", 
        x = "Theoretical - Limit Distribution", 
        y = "Sample"
      )
  })
  
  # Adaptive choice of parameter 1, according to selected distribution
  output$parameter1 <- renderUI({
    if (input$dist == "Normal") {
      label_par1 <- "Normal Mean Parameter"
      min_par1 <- NA
    }
    else if (input$dist == "Exponential") {
      label_par1 <- "Exponential Rate Parameter"
      min_par1 <- 0
    }
    else if (input$dist == "Binomial") {
      label_par1 <- "Binomial Size Parameter"
      min_par1 <- 0
    }
    else if (input$dist == "Poisson") {
      label_par1 <- "Poisson Mean Parameter"
      min_par1 <- 0
    }
    
    numericInput("parameter1", 
                 label_par1, 
                 value = 10, min = min_par1)
  })
  
  # Adaptive choice of parameter 2, according to selected distribution, may be
  # NULL for distributions with only one parameter
  output$parameter2 <- renderUI({
    if (input$dist == "Normal") {
      label_par2 <- "Normal Standard Deviation Parameter"
      min_par2 <- 0
      max_par2 <- NA
      value_par2 <- 1
      step_par2 <- 1
    }
    else if (input$dist == "Exponential") return(NULL)
    else if (input$dist == "Binomial") {
      label_par2 <- "Binomial Probability of Success Parameter"
      min_par2 <- 0
      max_par2 <- 1
      value_par2 <- 0.2
      step_par2 <- 0.01
    }
    else if (input$dist == "Poisson") return(NULL)
    
    numericInput("parameter2", 
                 label_par2, step = step_par2,
                 value = value_par2, min = min_par2, max = max_par2)
  })
})
