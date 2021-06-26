#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Author: Sara Soufsaf
# Email: sara_soufsaf@hotmail.com
# 2021-06-26

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Parallel first-order absorption "),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("alag1",
                        "Lag Time 1:",
                        min = 0,
                        max = 24,
                        value = 1),
            sliderInput("alag2",
                        "Lag time 2",
                        min = 0,
                        max = 24,
                        value = 4),
            checkboxGroupInput('showCMT',label = h4(''),
                               choices = list('Display the curve from the first absorption input (CMT1)' = 1,
                                              "Display the curve from the second absorption input (CMT2)" = 2,
                                              "Display the curve from the central compartment  (CMT3)" = 3),
                               selected = 3)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
))
