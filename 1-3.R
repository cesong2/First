setwd("C:/Users/tjoeun/Desktop/Rstudio")
load("./04_preprocess/04_preprocess.rdata")
apt_juso <-data.frame(apt_price$jibun)
apt_juso <- data.frame(apt_juso[!duplicated(apt_juso),])
head(apt_juso,2)

add_list<- list()
cnt<-0
kakao_key = "dd1a55d00619e73d0b127f69a82e3d76"
install.packages('httr')
library(httr)
install.packages("RJSONIO")
library(RJSONIO)
library(data.table)
library(dplyr)

#반복문을 통해 위도경도값 구하기