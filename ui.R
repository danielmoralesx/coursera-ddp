library(shiny)

shinyUI(navbarPage(
  "Illustrations for the Central Limit Theorem", 
  tabPanel("Plots", icon = icon("chart-bar"),
    sidebarLayout(
      sidebarPanel(
        radioButtons("dist", "Distribution", 
                     choices = c("Normal", 
                                 "Exponential", 
                                 "Binomial", 
                                 "Poisson")),
        htmlOutput("parameter1"),
        htmlOutput("parameter2"),
        numericInput("sample_size", 
                     "Sample Size - Chosen Distribution", 
                     value = 30,   min = 1),
        numericInput("N_means", 
                     "Mean Distribution Samples", 
                     value = 5000, min = 1)
      ),
      mainPanel(
        plotOutput("mean_dist_plot"),
        plotOutput("qqplot")
      )
    )
  ),
  tabPanel(
    "Documentation", 
    icon = icon("file-alt"),
    fluidPage(
      # Turn MathJax on to write LaTeX expressions
      withMathJax(),
      # Fix inline LaTeX for MathJax
      tags$div(HTML("<script type='text/x-mathjax-config' >
                MathJax.Hub.Config({
                tex2jax: {inlineMath: [['$','$']]}
                });
                </script >
                ")),
      helpText(paste(
        "Have you ever wanted to see the Central Limit Theorem in action? It",
        "is an asymptotic result that tells us about the distribution of the",
        "mean $\\bar{X}_n$ of a sequence of $n$ independent and identically",
        "distributed (i.i.d.) random variables drawn from a distribution with",
        "expected value $\\mu$ and finite variance $\\sigma^2$: for large $n$",
        "(or as $n \\to \\infty$), we have",
        "$$\\bar{X}_n \\sim N(\\mu, \\sigma^2 / n)$$"
      )),
      helpText(paste(
        "It is a powerful and general result that we can use to build",
        "confidence intervals, for example. But the theorem does not answer an",
        "important question for us to use this result, that is",
        "$$\\text{How large should } n \\text{ be?}$$"
      )),
      helpText(paste(
        "And this is the question we are investigating in this application,",
        "mainly due to a rule of thumb present in statistics, where it is said",
        "that $n = 30$ is good enough. Now you have a simple app to test that",
        "for some distributions:"
      )),
      helpText(tags$li(
        "Firstly, you select a distribution to draw samples from;"
      )),
      helpText(tags$li(paste(
        "Then, according to the distribution chosen, you can select its",
        "parameters;"
      ))),
      helpText(tags$li(
        'Now it is time select $n$ under "Sample Size - Chosen Distribution";'
      )),
      helpText(tags$li(paste(
        'The last input, "Mean Distribution Samples", is the real trick for',
        "our investigation: we are having this number of samples from the mean",
        "distribution in order to plot our graphs."
      ))),
      helpText(paste(
        "Having all the inputs, we can plot two graphs. The first one has more",
        "visual impact and compares a histogram from the samples of the mean",
        "distribution with the density of the asymptotic normal distribution.",
        "The second is more useful to analyse the fit and the convergence:",
        "it is a quantile-quantile plot with the same comparison."
      ))
    )
  )
))
