setwd('C:/Users/tjoeun/Desktop/01_code/coffee')
load("coffee_shop.rdata")
library(shiny)
library(leaflet)
library(ggplot2)
library(ggpmisc)
library(shiny)
library(leaflet)
library(leaflet.extras)
library(dplyr)

ui <- bootstrapPage(
  tags$style(type = "text/css","html, body {width:100%;height:100%}"),
  leafletOutput("map",width = "100%",height = "100%"),
  absolutePanel(top=10, right=10,
                selectInput(
                  inputId = "sel_brand",
                  label = tags$span(
                    style="color: black;","프랜차이즈를 선택해주세요"
                  ),
                  choices= unique(coffee_shop$brand),
                  selected= unique(coffee_shop$brand[2])
                ),
                sliderInput(
                  inputId = "range",
                  label=tags$span(
                    style="color: black;","접근성 범위를 선택해주세요"
                  ),
                  sep="",
                  min =0,
                  max = 100,
                  value = c(60,80),
                  step = 10),
                plotOutput("density",height = 230
                ),
  )
)

server <- function(input, output, session){
  brand_sel = reactive({
    brand_sel = subset(coffee_shop,brand ==input$sel_brand&metro_idx >= input$range[1]&metro_idx<=input$range[2])
  })
  plot_sel = reactive({
    plot_sel = subset(coffee_shop, brand==input$sel_brand)
  })
  output$density <- renderPlot({
    ggplot(data = with(density(plot_sel()$metro_idx),
                       data.frame(x,y)), mapping= aes(x =x, y=y))+
             geom_line()+xlim(0,100)+ xlab('접근성 지수')+ ylab('빈도')+ geom_vline(xintercept=input$range[1], color='red', size=0.5)+
             geom_vline(xintercept= input$range[2], color='red', size=0.5)+ theme(axis.text.y = element_blank(), axis.ticks.y=element_blank())
  })
  output$map <-renderLeaflet({
    leaflet(brand_sel(), width = "100%", height = "100%") %>% addTiles() %>% setView(lng=127.0381, lat =37.59512, zoom=11) %>% addPulseMarkers(lng=~x, lat=~y, label=~name,icon=makePulseIcon())
  })
  }
shinyApp(ui, server)

