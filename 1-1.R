setwd("C:/Users/tjoeun/Desktop/Rstudio")
loc <- read.csv("sigun_code.csv", fileEncoding="UTF-8")
getwd()
setwd('C:/workspace/r_shiny')
# 1단계 수집 대상 지역 설정
loc$code <- as.character(loc$code)
head(loc, 2)
# 2단계 수집 기간 설정
datelist <- seq(from= as.Date('2021-01-01'),
                to = as.Date('2021-12-31'),
                by = '1 month')
datelist <- format(datelist, format='%Y%m')
datelist[1:3]

# 3단계 인증키 입력
 
service_key <- "huEy2FccpR8mKLnAqpCZ99QdqUA%2FxwQtGysBZIpD3ML4Fc%2FEdqeprh8uNpLrIshd0%2BXkq1M95bMVvNb%2FzMXcDA%3D%3D"
# 4단계 요청목록 생성
# 4-1 요청 목록 만들기
url_list =　list() #빈리스 만들기
cnt <- 0 # 반복문 제어 변수 초기값 설정

#4-2 요청목록 채우기
for (i in 1:nrow(loc)) { # 구별
  for (j in 1:length(datelist)){ #날짜
    cnt <-  cnt + 1
    url_list[cnt] <- paste0("http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?",
                            "LAWD_CD=", loc[i,1],         # 지역코드
                            "&DEAL_YMD=", datelist[j],    # 수집월
                            "&numOfRows=", 100,           # 한번에 가져올 최대 자료 수
                            "&serviceKey=", service_key)  # 인증키
  }
  Sys.sleep(0.1) # 0.1초 멈춤
  msg <- paste0("[", i,"/",nrow(loc), "]  ", loc[i,3], " 의 크롤링 목록이 생성됨 => 총 [", cnt,"] 건")
  cat(msg, "\n\n")
}

length(url_list)
browseURL(paste0(url_list[1]))
#5단계 크롤링 실행
library(XML)
library(data.table)
library(stringr)
#임시 저장 리스트 만들기
raw_data <- list()
root_Node <- list()
total <- list()
dir.create("02_raw_data")
#자료요청하고 응답받기
for (i in 1:length(url_list)){
  raw_data[[i]] <- xmlTreeParse(url_list[i], useInternalNodes=TRUE, encoding = "utf-8")
  root_Node[[i]]<- xmlRoot(raw_data[[i]])
  #전체 거래건수 확인하기
  items<-root_Node[[i]][[2]][['items']]
  size <-xmlSize(items)
  for(m in 1:size){
    item_temp <- xmlSApply(items[[m]],xmlValue)
    item+temp_dt <- data.table(year = item_temp[4],
                               month = item_temp[7],
                               day = item_temp[8],
                               price = item_temp[1],
                               code= item_temp[12],
                               dong_nm=item_temp[5],
                               jibun = item_temp[11],
                               con_year = item_temp[3],
                               apt_nm = item_temp[6],
                               area = item_temp[9],
                               floor = item_temp[13])
    item[[m]] <- item_temp_dt
  }
  apt_bind <- rbindlist(item)
  region_nm <- subset(loc, code==str_sub(url_list[i],115,119))$addr_1
  month <- str_sub(url_list[i],130,135)
  path <- as.character(paste0(region_nm,"_",month,".csv"))
  write.csv(apt_bind, path)
  msg <- paste0("[",i,"/", length(url_list),"] 수집한 데이터를 [", path,"]에 저장 합니다.")
  cat(msg, "\n\n")}


files<- dir("./02_raw_data")
library(plyr)
install.packages("plyr")
apt_price <- ldply(as.list(paste0("./02_raw_data/",files)), read.csv, fileEncoding="UTF-8")
tail(apt_price,2)

dir.create("./03_integrated")
save(apt_price, file = "./03_integrated/03_apt_price.rdata")
write.csv(apt_price, "./03_integrated/03_apt_price.csv")
