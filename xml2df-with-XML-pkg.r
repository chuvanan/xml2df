
require(XML)
require(here)
require(tictoc)
tibble = tibble::tibble

## -----------------------------------------------------------------------------
## Helper functions
## -----------------------------------------------------------------------------


xpath_builder = function(tags, default_ns = "ns") {

    stopifnot(
        "`tags` is not a character vector" = is.character(tags),
        "`tags` cannot be a zero-length vector" = length(tags) > 0,
        "`default_ns` must be a length-one character vector" = is.character(default_ns) && length(default_ns) > 0 && nchar(default_ns) > 0
    )

    len = length(tags)
    if (len == 1L) out = sprintf(".//%s:%s", default_ns, tags)
    if (len > 1L) out = paste0(".", paste0(sprintf("//%s:", default_ns), tags, collapse = ""))
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


## document parsing ------------------------------------------------------------

doc = xmlInternalTreeParse(here("FR_FRAMDST66_2016-01.xml"))
trademarks = getNodeSet(doc, path = "//ns:TradeMark[@operationCode='Update']", namespaces = "ns")

class(trademarks)
## [1] "XMLNodeSet"

xmlSize(trademarks)
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
N = 100L # for demo
output = vector("list", N)

tic()
for (i in seq_len(N)) {
    res = lapply(selected_xpaths, function(xp) xpathSApply(trademarks[[i]], xp, xmlValue, namespaces = "ns"))
    names(res) = nms
    output[[i]] = make_tibble(res)
}
toc()
## 0.984 sec elapsed (pretty fast!!!)


output = do.call("rbind", output)
head(output)
##   ApplicationNumb… ApplicationDate FilingPlace ExpiryDate MarkImageFilena… ClassNumber ApplicantDetail… ApplicantDetail… ApplicantDetail…
##   <chr>            <chr>           <chr>       <chr>      <chr>            <named lis> <chr>            <chr>            <chr>
## 1 3046121          2000-08-09      INPI PARIS  2020-08-09 FMARK0000000003… <chr [1]>   786920306        1                CORA, SOCIETE P…
## 2 3047646          2000-08-18      STRASBOURG… 2020-08-18 FMARK0000000003… <chr [5]>   786920306        1                CORA, Société p…
## 3 3062575          2000-11-06      I.N.P.I. P… 2020-11-06 FMARK0000000003… <chr [3]>   786920306        1                CORA, SAS unipe…
## 4 3065287          2000-11-17      I.N.P.I. P… 2020-11-17 FMARK0000000003… <chr [4]>   786920306        1                CORA, société p…
## 5 3073011          2000-12-22      I.N.P.I. P… 2020-12-22 FMARK0000000003… <chr [19]>  786920306        1                CORA, SOCIETE P…
## 6 3074035          2000-12-29      I.N.P.I. P… 2020-12-29 FMARK0000000003… <chr [5]>   330814732        1                LAGARDERE SERVI…
## # … with 15 more variables: ApplicantDetails_OrganizationName <chr>, ApplicantDetails_AddressCountryCode <chr>,
## #   ApplicantDetails_AddressStreet <chr>, ApplicantDetails_AddressCity <chr>, ApplicantDetails_AddressPostcode <chr>,
## #   RepresentativeDetails_LastName <chr>, RepresentativeDetails_OrganizationName <chr>, RepresentativeDetails_AddressStreet <chr>,
## #   RepresentativeDetails_AddressCity <chr>, RepresentativeDetails_AddressPostcode <chr>, MarkRecordDetails_RecordIdentifier <named
## #   list>, MarkRecordDetails_RecordFilingDate <named list>, MarkRecordDetails_BasicRecordKind <named list>,
## #   MarkRecordDetails_RecordReference <named list>, MarkRecordDetails_PublicationDate <named list>
