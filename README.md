

## How hard is it to work with medium-sized XML file in R?


### Prerequisite

* R-4.0.0 (must)

* Command line setup:

```r
git clone https://github.com/chuvanan/xml2df.git
cd xml2df
R
renv::restore()
```

### Notes

* Main packages for working with XML in R: [xml2](https://github.com/r-lib/xml2)
  and [XML](http://www.omegahat.net/RSXML/). `xml2` is a R's bindings to
  [libxml2](http://xmlsoft.org/) - actually, a subset of `libxml2`. `XML`'s been
  developed by the legendary Duncan Temple Lang (R Core Team) - also based on
  `libxml2`.
