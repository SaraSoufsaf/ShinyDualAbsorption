#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Author: Sara Soufsaf
# Email: sara_soufsaf@hotmail.com
# 2021-06-26

library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # Creating a function called PKmodel
    #   It returns a list of concentrations for compartments 1, 2 and 3
    PKmodel  = function(alag1,alag2){
        
        t = seq(0, 24,0.1) #sampling times are from 0 to 24h, ever 0.1h
        D = 50 # fictional dose
        
        ## Typical PK parameters (from doi: 10.1089/cap.2018.0093)
        TVka1 = 0.182
        TVka2 = 0.258
        TVF1 = 0.557
        TVlag1 = alag1
        TVlag2 = alag2
        TVV = 816
        TVCl = 405
        TVke = TVCl/TVV # From physiological constants to micro-constants
        
        ## First-absorption times
        t1 = t - TVlag1     # Delay the original sampling times with the first lag time
        t1[t1<0] = 0        # Replace all negative values by 0
        
        ## Second-absorption times
        t2 = t - TVlag2     # Delay the original sampling times with the first lag time
        t2[t2<0] = 0        # Replace all negative values by 0
        
        ## Computing the Central Compartment concentrations
        #   Using PK equations for one compartment, first-order absorption and elimination. 
        #   Examples in : http://lixoft.com/wp-content/uploads/2016/03/PKPDlibrary.pdf
        
        
        #   Compartment 1 concentrations
        C_CMT1 = ((TVF1 * D *TVka1) / (TVV * (TVka1-TVke))) * (exp(-TVke * t1) - exp(-TVka1 *t1))
        
        #   Compartment 2 concentrations
        C_CMT2 = (((1-TVF1) * D *TVka2) / (TVV * (TVka2-TVke))) * (exp(-TVke * (t2)) - exp(-TVka1 *t2))
        
        #   Central compartment concentrations are the sum of CMT1 and CMT2
        C_CMT3 = (C_CMT1 + C_CMT2) 
        
        ## Adding all compartments into one list called Concentrations
        Concentrations = list (C_CMT1,C_CMT2,C_CMT3)
        
        ## The function will return the list
        return(Concentrations)
        
        
    }
    
    # Rendering the plot
    # This section will run everytime the user's input is changed
    output$distPlot <- renderPlot({
        
        # Computing the concentrations based on the chosen alag1 and alag2
        Concentrations = PKmodel(input$alag1,input$alag2)
        
        # Checking which bioequivalence to display
        showCMT1     = '1' %in% input$showCMT   #Indicator for CMT1
        showCMT2     = '2' %in% input$showCMT   #Indicator for CMT2
        showCMT3     = '3' %in% input$showCMT   #Indicator for CMT3
        
        # Building the dataframe as a tibble for easier coding
        dataset = tibble(Time= seq(0, 24,0.1) , #Time of sampling
                         CMT1 = Concentrations[[1]], #CMT1 concentrations
                         CMT2 = Concentrations[[2]], #CMT2 concentrations
                         CMT3 = Concentrations[[3]])%>% #CMT3 concentrations
            select(c(1,as.numeric(input$showCMT)+1)) %>% # Selecting the compartments according to the user's choice
            pivot_longer(matches("CMT"), #Pivoting the tibble for all columns that match the pattern CMT in their name
                         names_to = 'Compartment', #The Compartment numbers are in a new column called Compartment
                         values_to = 'Concentration') #The Values are into a new column called Concentration
        
        # Drawing the curves for each compartment
        ggplot(dataset,aes(Time,Concentration,color=Compartment))+
            geom_line(size=2)+ #Change the thickness of the line
            xlab('Time (h)')+ #Change the label of the x axis
            theme(axis.text.y = element_blank()) #Hide y axis text because the scale is not considered in this code
        
    })
    
})
