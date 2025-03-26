spanish_indicators <- data.frame(
  "Indicadores de salud del suelo" = c(
    "La proteína del suelo ACE",
    "La estabilidad de agregados",
    "Conductividad eléctrica (EC)",
    "El carbono potencialmente mineralizable (MinC)",
    "El carbono oxidable de permanganato (POXC)",
    "El nitrógeno potencialmente mineralizable (PMN)",
    "El pH del suelo",
    "Nitrógeno total",
    "Los nutrientes esenciales de las plantas",
    "Densidad aparente",
    "Capacidad de intercambio catiónico (CEC)",
    "La infiltración",
    "Materia organica (SOM)",
    "Capacidad de retención de agua (WHC)"
  ),
  "Función del suelo" = c(
    "Ciclo de nutrientes, biodiversidad y hábitat, filtración y resiliencia",
    "Soporte físico, relaciones hídricas, biodiversidad y hábitat, filtración y resiliencia",
    "Soporte físico, ciclo de nutrientes, filtración y resiliencia",
    "Ciclo de nutrientes, biodiversidad y hábitat, filtración y resiliencia",
    "Biodiversidad y hábitat, Ciclo de nutrientes, filtración y resiliencia",
    "Ciclo de nutrientes, biodiversidad y hábitat, filtración y resiliencia",
    "Nutrient cycling, filtración y resiliencia",
    "Ciclo de nutrientes, biodiversidad y hábitat, filtración y resiliencia",
    "Ciclo de nutrientes",
    "Soporte físico, relaciones hídricas, biodiversidad y hábitat, filtración y resiliencia",
    "Ciclo de nutrientes, filtración y resiliencia",
    "Relaciones hídricas, soporte físico",
    "Ciclo de nutrientes, filtración y resiliencia",
    "Relaciones hídricas, soporte físico"
  ),
  "Medir cada" = c(
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "1-3 años",
    "3-5 años",
    "3-5 años",
    "3-5 años",
    "3-5 años",
    "3-5 años"
  ),
  "Tipo de curva y mejoría" = c(
    "Más es mejor",
    "Más es mejor",
    "Menos es mejor",
    "Más es mejor",
    "Más es mejor",
    "Más es mejor",
    "Rango óptimo",
    "Rango óptimo",
    "Rango óptimo",
    "Rango óptimo",
    "Más es mejor",
    "Más es mejor",
    "Más es mejor",
    "Más es mejor"
  ),
  check.names = FALSE
)

write.csv(
  spanish_indicators,
  "quarto/spanish/indicators.csv",
  row.names = F,
  fileEncoding = "UTF-8"
)

english_indicators <- data.frame(
  "Soil Health Indicator" = c(
    "ACE Soil Protein",
    "Aggregate Stability",
    "Electrical Conductivity (EC)",
    "Mineralizable Carbon",
    "Permanganate Oxidizable Carbon (POXC)",
    "Potentially Mineralizable Nitrogen (PMN)",
    "Soil pH",
    "Total Nitrogen",
    "Plant Essential Nutrients",
    "Bulk Density",
    "Cation Exchange Capacity",
    "Infiltration",
    "Soil Organic Matter (SOM)",
    "Water Holding Capacity (WHC)"
  ),
  "Soil Function" = c(
    "Nutrient cycling, biodiversity & habitat, filtering & resilience",
    "Physical support, water relations, biodiversity & habitat, filtering & resilience",
    "Physical support, nutrient cycling, filtering & resilience",
    "Nutrient cycling, biodiversity & habitat, filtering & resilience",
    "Biodiversity & habitat, nutrient cycling, filtering & resilience",
    "Nutrient cycling, biodiversity & habitat, filtering & resilience",
    "Nutrient cycling, filtering & resilience",
    "Nutrient cycling, biodiversity & habitat, filtering & resilience",
    "Nutrient cycling",
    "Physical support, water relations, biodiversity & habitat, filtering & resilience",
    "Nutrient cycling, filtering & resilience",
    "Water relations, physical support",
    "Nutrient cycling, filtering & resilience",
    "Water relations, physical support"
  ),
  "Measure every" = c(
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "1-3 years",
    "3-5 years",
    "3-5 years",
    "3-5 years",
    "3-5 years",
    "3-5 years"
  ),
  "Scoring Curve Type" = c(
    "More is better",
    "More is better",
    "Less is better",
    "More is better",
    "More is better",
    "More is better",
    "Optimal range",
    "Optimal range",
    "Optimal range",
    "Optimal range",
    "More is better",
    "More is better",
    "More is better",
    "More is better"
  ),
  check.names = FALSE
)

write.csv(
  english_indicators,
  "quarto/english/indicators.csv",
  row.names = F,
  fileEncoding = "UTF-8"
)
