

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
  `libxml2`. In general, `xml2` will be easier to use for simple tasks thanks to
  its user-friendly API (more on that later) while `XML` should be preferred for
  heavier and more complicated tasks.

* How a XML parser works (for example: `libxml2`)?

* Rules for building xpath query:
  * Place two backslashes in front of the top node for jumping across nodes
  * Separate subsequent nodes with a single backslash
  * Add a period before search query to make the search to be local (that's
    particularly useful when looping over nodesets)

### Resources

* [Libxml Tutorial](http://xmlsoft.org/tutorial/index.html)

* [XML - Namespaces](https://www.tutorialspoint.com/xml/xml_namespaces.htm)

* [Quick Guide to XML in R](https://lecy.github.io/Open-Data-for-Nonprofit-Research/Quick_Guide_to_XML_in_R.html)
