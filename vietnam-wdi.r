


require(here)
require(tictoc)

extract_record = function(path) {

    withr::local_package(package = "XML")

    stopifnot(
        "`path` does not exist." = file.exists(path)
    )

    doc = xmlInternalTreeParse(path)

    ## define xpath queries
    country_area_xp = "//field[@name='Country or Area']"
    country_key_xp = "//field[@name='Country or Area']/@key"
    item_xp = "//field[@name='Item']"
    item_key_xp = "//field[@name='Item']/@key"
    year_xp = "//field[@name='Year']"
    value_xp = "//field[@name='Value']"

    ## pull data out of the document
    out = data.frame(
        country_area = xpathSApply(doc, country_area_xp, xmlValue),
        country_key = xpathSApply(doc, country_key_xp),
        item = xpathSApply(doc, item_xp, xmlValue),
        item_key = xpathSApply(doc, item_key_xp),
        year = as.integer(xpathSApply(doc, year_xp, xmlValue)),
        value = as.numeric(xpathSApply(doc, value_xp, xmlValue))
    )

    out
}

tic()
res = extract_record(here("API_VNM_DS2_en_xml_v2_990115.xml"))
toc()
## 5.457 sec elapsed

## write.csv(res, file = here("vietnam-wdi.csv"), quote = FALSE, row.names = FALSE)
