

require(here)
require(xml2)
require(tictoc) # for fun
tibble = tibble::tibble


## helper functions ------------------------------------------------------------

xpath_builder = function(tags) {

    stopifnot(
        "`tags` is not a character vector" = is.character(tags),
        "`tags` cannot be a zero-length vector" = length(tags) > 0
    )

    len = length(tags)
    ## note: `.` makes search to be local
    if (len == 1L) out = sprintf(".//d1:%s", tags)
    if (len > 1L) out = paste0(".", paste0("//d1:", tags, collapse = ""))
    out
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

        ApplicantDetails_ApplicantIdentifier = as_is(res["ApplicantDetails_ApplicantIdentifier"]),
        ApplicantDetails_ApplicantSequenceNumber = as_is(res["ApplicantDetails_ApplicantSequenceNumber"]),
        ApplicantDetails_LastName = as_is(res["ApplicantDetails_LastName"]),
        ApplicantDetails_OrganizationName = as_is(res["ApplicantDetails_OrganizationName"]),
        ApplicantDetails_AddressCountryCode = as_is(res["ApplicantDetails_AddressCountryCode"]),
        ApplicantDetails_AddressStreet = as_is(res["ApplicantDetails_AddressStreet"]),
        ApplicantDetails_AddressCity = as_is(res["ApplicantDetails_AddressCity"]),
        ApplicantDetails_AddressPostcode = as_is(res["ApplicantDetails_AddressPostcode"]),

        RepresentativeDetails_LastName = as_is(res["RepresentativeDetails_LastName"]),
        RepresentativeDetails_OrganizationName = as_is(res["RepresentativeDetails_OrganizationName"]),
        RepresentativeDetails_AddressStreet = as_is(res["RepresentativeDetails_AddressStreet"]),
        RepresentativeDetails_AddressCity = as_is(res["RepresentativeDetails_AddressCity"]),
        RepresentativeDetails_AddressPostcode = as_is(res["RepresentativeDetails_AddressPostcode"]),

        MarkRecordDetails_RecordIdentifier = as_is(res["MarkRecordDetails_RecordIdentifier"]),
        MarkRecordDetails_RecordFilingDate = as_is(res["MarkRecordDetails_RecordFilingDate"]),
        MarkRecordDetails_BasicRecordKind = as_is(res["MarkRecordDetails_BasicRecordKind"]),
        MarkRecordDetails_RecordReference = as_is(res["MarkRecordDetails_RecordReference"]),
        MarkRecordDetails_PublicationDate = as_is(res["MarkRecordDetails_PublicationDate"])
    )
    out
}


## xml extractor ---------------------------------------------------------------

transaction = read_xml(here("FR_FRAMDST66_2016-01.xml"), encoding = "UTF-8")
trademarks = xml_find_all(transaction, xpath = "//d1:TradeMark[@operationCode='Update']")

class(trademarks)
## [1] "xml_nodeset"
NROW(trademarks)
## [1] 5619


selected_tags = list(
    "ApplicationNumber",
    "ApplicationDate",
    "FilingPlace",
    "ExpiryDate",
    "MarkImageFilename",
    "ClassNumber",
    c("ApplicantDetails", "ApplicantIdentifier"),
    c("ApplicantDetails", "ApplicantSequenceNumber"),
    c("ApplicantDetails", "LastName"),
    c("ApplicantDetails", "OrganizationName"),
    c("ApplicantDetails", "AddressCountryCode"),
    c("ApplicantDetails", "AddressStreet"),
    c("ApplicantDetails", "AddressCity"),
    c("ApplicantDetails", "AddressPostcode"),
    c("RepresentativeDetails", "LastName"),
    c("RepresentativeDetails", "OrganizationName"),
    c("RepresentativeDetails", "AddressStreet"),
    c("RepresentativeDetails", "AddressCity"),
    c("RepresentativeDetails", "AddressPostcode"),
    c("MarkRecordDetails", "RecordIdentifier"),
    c("MarkRecordDetails", "RecordFilingDate"),
    c("MarkRecordDetails", "BasicRecordKind"),
    c("MarkRecordDetails", "BasicRecordKind"),
    c("MarkRecordDetails", "RecordReference"),
    c("MarkRecordDetails", "PublicationDate")
)

selected_xpaths = vapply(selected_tags, xpath_builder, character(1L))
nms = vapply(selected_tags, function(s) if (length(s) == 1L) return(s) else paste0(s, collapse = "_"), character(1L))


## N = NROW(trademarks)
N = 10L # for demo
output = vector("list", N)


tic()
for (i in seq_len(N)) {
    res = lapply(selected_xpaths, function(t) xml_text(xml_find_all(trademarks[[i]], xpath = t)))
    names(res) = nms
    output[[i]] = make_tibble(res)
}
toc()
## 2.737 sec elapsed


output = do.call("rbind", output)
head(output)
## # A tibble: 6 x 24
##   ApplicationNumb… ApplicationDate FilingPlace ExpiryDate MarkImageFilena… ClassNumber
##   <chr>            <chr>           <chr>       <chr>      <chr>            <named lis>
## 1 3046121          2000-08-09      INPI PARIS  2020-08-09 FMARK0000000003… <chr [1]>
## 2 3047646          2000-08-18      STRASBOURG… 2020-08-18 FMARK0000000003… <chr [5]>
## 3 3062575          2000-11-06      I.N.P.I. P… 2020-11-06 FMARK0000000003… <chr [3]>
## 4 3065287          2000-11-17      I.N.P.I. P… 2020-11-17 FMARK0000000003… <chr [4]>
## 5 3073011          2000-12-22      I.N.P.I. P… 2020-12-22 FMARK0000000003… <chr [19]>
## 6 3074035          2000-12-29      I.N.P.I. P… 2020-12-29 FMARK0000000003… <chr [5]>
## # … with 18 more variables: ApplicantDetails_ApplicantIdentifier <chr>,
## #   ApplicantDetails_ApplicantSequenceNumber <chr>, ApplicantDetails_LastName <chr>,
## #   ApplicantDetails_OrganizationName <chr>, ApplicantDetails_AddressCountryCode <chr>,
## #   ApplicantDetails_AddressStreet <chr>, ApplicantDetails_AddressCity <chr>,
## #   ApplicantDetails_AddressPostcode <chr>, RepresentativeDetails_LastName <chr>,
## #   RepresentativeDetails_OrganizationName <chr>, RepresentativeDetails_AddressStreet <chr>,
## #   RepresentativeDetails_AddressCity <chr>, RepresentativeDetails_AddressPostcode <chr>,
## #   MarkRecordDetails_RecordIdentifier <chr>, MarkRecordDetails_RecordFilingDate <chr>,
## #   MarkRecordDetails_BasicRecordKind <chr>, MarkRecordDetails_RecordReference <chr>,
## #   MarkRecordDetails_PublicationDate <chr>
