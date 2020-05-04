

require(here)
require(xml2)
require(tictoc) # for fun
tibble = tibble::tibble


## helper functions ------------------------------------------------------------

find_element = function(x, tag) {

    if (missing(tag)) stop("Argument `tag` is missing, with no default", call. = FALSE)
    contents = xml_contents(x)

    if (length(contents) == 0L) {
        parent = xml_parent(x)
        found = xml_name(parent) == tag
        if (found) return(xml_text(parent))
        out = list()
    } else {
        ## Naming element adopted from https://github.com/r-lib/xml2/blob/master/R/as_list.R#L62
        out = lapply(seq_along(contents), function(i) find_element(contents[[i]], tag))
        nms = ifelse(xml_type(contents) == "element", xml_name(contents), "")
        names(out) = nms
    }

    unlist(out)
}

make_tibble = function(res) {

    stopifnot(
        "`res` is not a list" = is.list(res),
        "`res` is not a named list" = length(names(res)) > 0
    )

    as_is = function(x) {
        if (lengths(x) > 1L) return(x)
        if (lengths(x) == 1L) return(x[[1L]])
        if (lengths(x) == 0L) return(NA_character_)
    }

    out = tibble(
        ApplicationNumber = as_is(res["ApplicationNumber"]),
        ApplicationDate = as_is(res["ApplicationDate"]),
        FilingPlace = as_is(res["FilingPlace"]),
        ExpiryDate = as_is(res["ExpiryDate"]),
        MarkImageFilename = as_is(res["MarkImageFilename"]),
        ClassNumber = as_is(res["ClassNumber"]),
        ApplicantIdentifier = as_is(res["ApplicantIdentifier"]),
        ApplicantSequenceNumber = as_is(res["ApplicantSequenceNumber"]),
        LastName = as_is(res["LastName"]),
        OrganizationName = as_is(res["OrganizationName"]),
        AddressCountryCode = as_is(res["AddressCountryCode"]),
        AddressStreet = as_is(res["AddressStreet"]),
        AddressCity = as_is(res["AddressCity"]),
        AddressPostcode = as_is(res["AddressPostcode"]),
        RecordIdentifier = as_is(res["RecordIdentifier"]),
        RecordFilingDate = as_is(res["RecordFilingDate"]),
        BasicRecordKind = as_is(res["BasicRecordKind"]),
        RecordReference = as_is(res["RecordReference"]),
        PublicationDate = as_is(res["PublicationDate"])
    )
    out
}


## xml extractor ---------------------------------------------------------------

transaction = read_xml(here("FR_FRAMDST66_2016-01.xml"), encoding = "UTF-8")

selected_tags = c("ApplicationNumber", "ApplicationDate", "FilingPlace",
                  "ExpiryDate", "MarkImageFilename", "ClassNumber",
                  "ApplicantIdentifier", "ApplicantSequenceNumber", "LastName",
                  "OrganizationName", "AddressCountryCode", "AddressStreet",
                  "AddressCity", "AddressPostcode", "RecordIdentifier",
                  "RecordFilingDate", "BasicRecordKind", "RecordReference",
                  "PublicationDate")

trademark_details = xml_contents(xml_find_all(transaction, xpath = "/*/*[2]/*/*/*"))
NROW(trademark_details)
## [1] 5619


## N = NROW(trademark_details)
N = 100L # for demo
output = list("vector", N)


tic()
for (i in seq_len(N)) {
    res = lapply(selected_tags, function(t) find_element(trademark_details[[i]], t))
    names(res) = selected_tags
    output[[i]] = make_tibble(res)
}
toc()
## 13.154 sec elapsed


output = do.call("rbind", output)
head(output)
## # A tibble: 6 x 19
##   ApplicationNumb… ApplicationDate FilingPlace ExpiryDate MarkImageFilena… ClassNumber ApplicantIdenti… ApplicantSequen… LastName
##   <chr>            <chr>           <chr>       <chr>      <chr>            <named lis> <chr>            <chr>            <named >
## 1 3046121          2000-08-09      INPI PARIS  2020-08-09 FMARK0000000003… <chr [1]>   786920306        1                <chr [3…
## 2 3047646          2000-08-18      STRASBOURG… 2020-08-18 FMARK0000000003… <chr [5]>   786920306        1                <chr [3…
## 3 3062575          2000-11-06      I.N.P.I. P… 2020-11-06 FMARK0000000003… <chr [3]>   786920306        1                <chr [4…
## 4 3065287          2000-11-17      I.N.P.I. P… 2020-11-17 FMARK0000000003… <chr [4]>   786920306        1                <chr [3…
## 5 3073011          2000-12-22      I.N.P.I. P… 2020-12-22 FMARK0000000003… <chr [19]>  786920306        1                <chr [3…
## 6 3074035          2000-12-29      I.N.P.I. P… 2020-12-29 FMARK0000000003… <chr [5]>   330814732        1                <chr [7…
## # … with 10 more variables: OrganizationName <named list>, AddressCountryCode <named list>, AddressStreet <named list>,
## #   AddressCity <named list>, AddressPostcode <named list>, RecordIdentifier <named list>, RecordFilingDate <named list>,
## #   BasicRecordKind <named list>, RecordReference <named list>, PublicationDate <named list>
