## https://www.yr.no/place/Viet_Nam/H%E1%BB%93_Ch%C3%AD_Minh/Ho_Chi_Minh_City/forecast.xml



## -----------------------------------------------------------------------------
## Helper functions
## -----------------------------------------------------------------------------


require(here)
require(XML)


get_weather_location = function(path) {

    stopifnot(
        "`path` does not exist." = file.exists(path)
    )

    doc = xmlInternalTreeParse(path)
    out = data.frame(
        name = xpathSApply(doc, path = "//location/name", xmlValue),
        type = xpathSApply(doc, path = "//location/type", xmlValue),
        country = xpathSApply(doc, path = "//location/country", xmlValue),
        timezone_id = xpathSApply(doc, path = "//location/timezone", xmlGetAttr, "id"),
        timezone_offset = as.numeric(xpathSApply(doc, path = "//location/timezone", xmlGetAttr, "utcoffsetMinutes")),
        altitude = as.numeric(xpathSApply(doc, path = "//location/location", xmlGetAttr, "altitude")),
        latitude = as.numeric(xpathSApply(doc, path = "//location/location", xmlGetAttr, "latitude")),
        longitude = as.numeric(xpathSApply(doc, path = "//location/location", xmlGetAttr, "longitude")),
        geobaseid = as.numeric(xpathSApply(doc, path = "//location/location", xmlGetAttr, "geobaseid"))
    )
    free(doc)
    out
}


get_weather_meta = function(path) {

    stopifnot(
        "`path` does not exist." = file.exists(path)
    )

    doc = xmlInternalTreeParse(path)
    out = data.frame(
        last_update = xpathSApply(doc, path = "//meta/lastupdate", xmlValue),
        next_update = xpathSApply(doc, path = "//meta/nextupdate", xmlValue)
    )
    free(doc)

    out[] = lapply(out, function(t) as.POSIXct(t, format = "%Y-%m-%dT%H:%M:%S"))
    out
}


get_weather_forecast = function(path) {

    stopifnot(
        "`path` does not exist." = file.exists(path)
    )

    doc = xmlInternalTreeParse(path)
    out = data.frame(
        from = xpathSApply(doc, path = "//tabular/time", xmlGetAttr, "from"),
        to = xpathSApply(doc, path = "//tabular/time", xmlGetAttr, "to"),
        symbol = xpathSApply(doc, path = "//tabular//symbol", xmlGetAttr, "name"),
        precipitation = xpathSApply(doc, path = "//tabular//precipitation", xmlGetAttr, "value"),
        wind_direction_deg = xpathSApply(doc, path = "//tabular//windDirection", xmlGetAttr, "deg"),
        wind_direction_code = xpathSApply(doc, path = "//tabular//windDirection", xmlGetAttr, "code"),
        wind_direction_name = xpathSApply(doc, path = "//tabular//windDirection", xmlGetAttr, "name"),
        wind_speed_mps = xpathSApply(doc, path = "//tabular//windSpeed", xmlGetAttr, "mps"),
        wind_speed_name = xpathSApply(doc, path = "//tabular//windSpeed", xmlGetAttr, "name"),
        temperature_value = xpathSApply(doc, path = "//tabular//temperature", xmlGetAttr, "value"),
        temperature_unit = xpathSApply(doc, path = "//tabular//temperature", xmlGetAttr, "unit"),
        pressure_value = xpathSApply(doc, path = "//tabular//temperature", xmlGetAttr, "value"),
        pressure_unit = xpathSApply(doc, path = "//tabular//temperature", xmlGetAttr, "unit")
    )
    free(doc)

    date_cols = c("from", "to")
    out[, date_cols] = lapply(out[, date_cols], function(t) as.POSIXct(t, format = "%Y-%m-%dT%H:%M:%S"))
    num_cols = c("precipitation", "wind_direction_deg", "wind_speed_mps", "temperature_value", "pressure_value")
    out[, num_cols] = lapply(out[, num_cols], as.numeric)

    out
}

## -----------------------------------------------------------------------------
## Pull data
## -----------------------------------------------------------------------------

weather_location = get_weather_location(here("forecast_hour_by_hour.xml"))
weather_meta = get_weather_meta(here("forecast_hour_by_hour.xml"))
weather_forecast = get_weather_forecast(here("forecast_hour_by_hour.xml"))


head(weather_meta)
##           last_update         next_update
## 1 2020-05-12 20:15:09 2020-05-13 02:26:13

head(weather_location)
##               name             type  country      timezone_id timezone_offset altitude latitude longitude geobaseid
## 1 Ho Chi Minh City Regional capital Viet Nam Asia/Ho_Chi_Minh             420        7 10.82302  106.6296   1566083

head(weather_forecast)
##                  from                  to             symbol precipitation wind_direction_deg wind_direction_code wind_direction_name
## 1 2020-05-12 22:00:00 2020-05-12 23:00:00      Partly cloudy           0.0              133.4                  SE           Southeast
## 2 2020-05-12 23:00:00 2020-05-13 00:00:00      Partly cloudy           0.0              137.0                  SE           Southeast
## 3 2020-05-13 00:00:00 2020-05-13 01:00:00      Partly cloudy           0.1              137.3                  SE           Southeast
## 4 2020-05-13 01:00:00 2020-05-13 02:00:00         Light rain           0.2              138.8                  SE           Southeast
## 5 2020-05-13 02:00:00 2020-05-13 03:00:00 Light rain showers           0.2              137.4                  SE           Southeast
## 6 2020-05-13 03:00:00 2020-05-13 04:00:00      Partly cloudy           0.0              139.4                  SE           Southeast
##   wind_speed_mps wind_speed_name temperature_value temperature_unit pressure_value pressure_unit
## 1            4.2   Gentle breeze                29          celsius             29       celsius
## 2            3.5   Gentle breeze                29          celsius             29       celsius
## 3            2.7    Light breeze                29          celsius             29       celsius
## 4            2.8    Light breeze                29          celsius             29       celsius
## 5            2.1    Light breeze                28          celsius             28       celsius
## 6            3.2    Light breeze                28          celsius             28       celsius
