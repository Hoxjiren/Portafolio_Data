setwd("C:/Users/Admin/Desktop/portafolio/Rcurso") #establecemos el directorio de trabajo

#declaramos las librerías que utilizaré para el análisis
library(readxl)
library(dplyr)
library(foreign)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(ggrepel)

#Cargamos el dataframe de u archivo csv
data <- read.csv("COVID19_line_list_data.csv")
glimpse(data) #Un vistazo de las columnas y los datos en ella

data %>% 
  select(X.1:X.6) %>% #Comprobamos que las columnas del final están vacías
  summary

df <- data %>% 
  select(c(1,3,6,7,8,9,10,11,12,13,14,17,18,19)) #Limpiamos el df con las columnas que nos interesan
write.csv(df, "df.covid19.csv")


#1.- ¿Cuál es el porcentaje de supervivencia y fallecimiento de los pacientes ingresados?

df %>% 
  distinct(death)#En algunos casos está la fecha de fallecimiento en lugar de "1"

m_mortalidad <- df %>% #Las respuestas se guardan como una tabla de medidas
  as_tibble() %>% 
  mutate(
    across(c(death,recovered), ~ case_when(. != 0 ~ 1,  #Homogenización de los datos
                                            T ~ 0)),
    death = ifelse(death== 0, "Sobrevivió", "Falleció"),#Dejo la columna death, dando por hecho que "0" indica sobreviviencia
    Estado = death
  ) %>%
  count(Estado) %>%
  reframe(Estado,porcentaje=100* n/sum(n)) 
write.csv(m_mortalidad, "m_mortalidad.csv")


g_mortalidad <- m_mortalidad %>%    #Con la biblioteca ggplot graficamos los porcentajes de sobrevivientes y fallecidos
  ggplot(aes(x = "", y = porcentaje, fill = Estado)) +
  geom_col() +
  coord_polar(theta = "y")+ #Una gráfica de pastel
  geom_text(aes(label=round(porcentaje,1)), hjust=1.7)+ #Detalles de estilo
  labs(title = "Índice de mortalidad",
       subtitle = "Año 2020",
       caption = "Gráfico de elaboración propia")+ #Informaciónn de título, subtítulo y referencia
  theme(axis.title = element_blank(),
        legend.title = element_blank())
ggsave("mortalidad.png", plot = g_mortalidad, width = 7, height = 5, dpi = 300)

unique(df$country) #Aunque los primeros datos son de China, la tabla abarca varios países
#Así que el análisis continuó con una clasificación por país




#2.- Distribución de FALLECIMIENTOS por PAÏS

#Se homogenizan los datos definitivamente porque volveré a usar la variable
df <- df %>%    
  mutate(     
    across(c(death, recovered), ~ case_when(. != 0 ~ 1,  
                                            T ~ 0)),
    death = ifelse(death== 0, "Sobrevivió", "Falleció")
    ) 


m_m.pais <- df %>% #Se guarda como una tabla de medidas
  mutate(
    Estado = death,
    Pais = country
  ) %>%
  group_by(Pais, Estado) %>% 
  count() %>%
  ungroup() %>% 
  reframe( Pais,
            Estado,  #Calculo los porcentajes por país del total de casos
            prc=n/sum(n)*100) %>% 
  filter(Estado== "Falleció")  #Se filtran los datos para los fallecimientos
write.csv(m_m.pais, file = "mort_pais.csv")  

g_m.pais <- m_m.pais %>% 
  ggplot(aes(x=Pais, y=prc))+
  geom_col(aes(fill=Pais))+
  labs(title= "Tasa de mortalidad por país",
       caption= "Gráfico de elaboración propia",
       x= "País", y= "Tasa de mortalidad")+
  scale_fill_manual(values = c("China"= "blue4",
                    "France"="grey1",
                    "Hong Kong"= "red4",
                    "Iran"="orange4",     #Como se detectó al inicio, hay más reportes de China que de otros países
                    "Japan"= "green4",    #Lo cual genera un sesgo
                    "Phillipines"="yellow4",
                    "South Korea"= "brown4",
                    "Taiwan"= "darkblue"))
  ggsave("mort_pais.png",plot = g_m.pais, width = 7, height = 5, dpi = 300)


#3.- Prueba de HIPÓTESIS: A MÁS EDAD, MAYOR MORTALIDAD

m_edad <- df %>%  #Se guarda como una tabla con las medias de edad por Estado
  mutate(
    Estado= death
   ) %>% 
  group_by(Estado) %>% #Se calcula la media de edad para los dos grupos "Sobrevivió" y "Falleció"
  summarise(edadprom = mean(age, na.rm = T)) #no consideramos lo valores NA
write.csv(m_edad, file = "mort_edad.csv")

#Se observa que el grupo de fallecimientos tiene una media de edad más alta
#Para comprobar si es una diferencia estadísticamente significativa aplicamos la prueba de T de Student o t.test
#Para el t.test se necesitan las medias por separado


#Calcular media para sobrevivientes
vivo <- df %>%
  as_tibble() %>%   #Convertimos la tabla tibble para facilitar su visualización
  select(6,12) %>%   #seleccionamos sólo la columna de edad y fallecimiento
  filter(death=="Sobrevivió")

#Calcular la media para fallecimientos
muerto <- df %>% 
  as_tibble() %>%   #Repetimos los pasos para facilitar su visualización
  select(6,12) %>%
  filter(death=="Falleció")

#Prueba de t de Student
#Hipótesis nula: la edad no tiene efecto en la mortalidad
t.test(muerto$age, vivo$age ,alternative="two.sided", conf.level = 0.95)
#Sí hay una variación estadísticamente relevante entre las dos medias de edad 
#como se observa en el elevado valor de T
#Igualmente, el valor p cercano a 0 nos permite rechazar la hipótesis nula


#Grafica de densidad para observar la distribución por fallecimiento y supervivencia

g_edad <- df %>%
  ggplot(aes(x=age))+
  geom_density(color = 4,lwd = 1,linetype = 1, fill = 4, alpha = 0.25)+
  facet_wrap(vars(death))+  #Para mostrar dos g´raficas por cada Estado
  labs(title = "Edad de pacientes que murieron o sobrevivieron",
       x="Edad", y="",
       caption= "Gráfico de elaboración propia")
ggsave("mort_edad.png",plot = g_edad, width = 7, height = 5, dpi = 300)

#Se observa que hay un pico en los fallecimientos a partir de los 50 años
#Aunque la distribución de la gráfica de sobrevivientes es más plana
#hay un pico entre 50-60 años, que podría explicarse por la edad de los pacientes ingresados

df %>% 
  group_by(age) %>% 
  count() %>% 
  ggplot(aes(x=age,y=n))+
  geom_col(color = 3,lwd = 1,linetype = 1, fill = 4, alpha = 0.25)
  
#Hay más pacientes en el intervalo de 50-75
#lo cual influye en la distribución de pacientes sobrevivientes



#4.- Prueba de Hipótesis: HAY UNA DIFERENCIA SIGNIFICATIVA DE MORTALIDAD POR GÉNERO

#SE calcula la mortalidad por género
df1 <- df %>% 
  select(gender, death) %>% 
  na.omit(gender) %>%   #Hay filas NA
  mutate(
    death = ifelse(death== "Falleció", 1, 0)  #regresamos los valores de death para calcular las medias
  )


#Preparamos nuestro subset para la prueba t
MH <- df1 %>%
  subset(gender== "male")

MF <- df1 %>% 
  subset(gender== "female") 

t.test(MH$death, MF$death, alternative="two.sided", conf.level = 0.95)
#COn un valor t de 3.084, concluimos que hay una diferencia significativa
#el valor p es cercano a 0 por lo que rechazamos la hipótesis nula

#Calculamos, del total de pacientes, los porcentajes de supervivencia y mortalidad por género
m_m.genero <- df1 %>%   #Guardamos como tabla de medidas
  group_by(gender,death) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(Porcentaje= 100*n/sum(n))
write.csv(m_m.genero, file = "mort_genero.csv")

#Gráfica de los porcentajes por género y Estado de supervivencia
g_genero <- m_m.genero %>%
  mutate(death=as.character(death),
         gender= ifelse(gender== "female", "Mujeres", "Hombres")) %>% 
  ggplot(aes(x = death, y=Porcentaje)) +
  geom_col(aes(fill=gender))+
  scale_fill_manual(values = c("Hombres" = "orange2", "Mujeres" = "purple2")) +
  scale_x_discrete(labels = c("Sobrevivientes", "Fallecidos"))+
  geom_text_repel(aes(label = round(Porcentaje,1), vjust = 1.6))+
  theme(axis.title.x = element_blank(),
        plot.caption = element_text(hjust = 0))+
  labs(title = "Porcentaje de supervivencia y fallecimientos por género ",
       fill="Género",
       x="", y= "Porcentaje",
       caption= "Datos obtenidos de:\n https://www.kaggle.com/datasets/sudalairajkumar/novel-corona-virus-2019-dataset/versions/25?resource=download")
#Esta gráfica muestra el porcentaje de sobrevivientes y fallecidos por género
ggsave("mort_genero.png",plot = g_genero, width = 7, height = 5, dpi = 300)

#5.- Días transcurridos entre los síntomas y el ingreso al hospital por país

m_diasintoma <- df %>% #Tabla de medidas, promedio de dias entre síntomas y hospitalización
  mutate(
    across(c(symptom_onset,hosp_visit_date), ~ as.Date(., format="%m/%d/%y")),  #cambiar el formato ya que algunas fechas tienen el año completo
    diasintoma= as.numeric(hosp_visit_date-symptom_onset),
    diasintoma= case_when(diasintoma< -300~ 365+diasintoma,
                          T~diasintoma) #las fechas de 2019 las convierte en 2020 por lo que salen resultados negativos, con esta operación obtenemos la diferencia real
    ) %>%  
  na.omit(diasintoma) %>% 
  group_by(country) %>%   #Agrupamos
  summarise(dias= round(mean(diasintoma, na.rm = T), 1))
write.csv(m_diasintoma, file ="diasintoma.csv")

#Grafica de los días entre los primeros síntomas y la hospitalización
g_diasintoma <- m_diasintoma %>% 
  ggplot(aes(x=country, y=dias, fill=country))+
  geom_col()+
  geom_text(aes(label = dias), vjust = -0.5)+
  scale_x_discrete(labels = c("China", "Alemania", "Hong Kong", "Japón","Singapur", "Corea del Sur","Taiwan"))+
  theme(legend.position = "none")+
  labs(title = "Promedio de días entre la aparición de síntomas y visita al hospital",
       x="", y= "Días",
       caption= "Datos obtenidos de:\n https://www.kaggle.com/datasets/sudalairajkumar/novel-corona-virus-2019-dataset/versions/25?resource=download")
ggsave("diasintoma.png",plot = g_diasintoma, width = 7, height = 5, dpi = 300)
