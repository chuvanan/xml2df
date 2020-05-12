

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
  * When things go wrong, it's likely due to namespace


### Strategies for extracting data from HTML/XML documents

* Always look at the data. What I mean by "look at the data" is to look at the
  XML file line by line to have a quick overview of structure, nesting depth,
  elements, attributes, namespaces (if any). For this task, command line tools
  such as `head`, `tail`, `less` become very handy.

  My favorite utility is `less`. I can view and naviage a big XML file very
  quickly with a few keystrokes (`G`: go to the end of file, `g`: go to start of
  file, `space`: page down, `b`: page up)

  Don't try to open a big file in editor or browser.

* Work with a small subset of data first. That's a generally good practice
  applying well to this situation. There are two main reasons:
  * To save time. Reading and processing large XML files can be time-consuming,
    especially when repeated several times before reaching the right
    solution (it happens more often than you think).
  * To facilitate solution design. Usually, XML document's structure has the
    same layout (branches, elements) at different levels (nodesets). You don't
    need a whole document (= hundreds of thousands elements), just a couple of
    elements in each nodesets is enough for programming.

### Sample projects

* [dvhc-vietnam](https://github.com/chuvanan/dvhc-vietnam): Convert Vietnam's
  administrative divisions data from XML to CSV/JSON

* [sdmx](https://github.com/chuvanan/sdmx): Vietnam's National Summary Data

* [vietnam-wdi](https://github.com/chuvanan/xml2df/blob/master/vietnam-wdi.r):
  Parse WorldBank's Vietnam World Development Indicators.

* [weather-forecast](https://github.com/chuvanan/xml2df/blob/master/xml-weather-forecast.r):
  Parse weather forecast XML service

### Resources

* [Libxml Tutorial](http://xmlsoft.org/tutorial/index.html)

* [XML - Namespaces](https://www.tutorialspoint.com/xml/xml_namespaces.htm)

* [Quick Guide to XML in R](https://lecy.github.io/Open-Data-for-Nonprofit-Research/Quick_Guide_to_XML_in_R.html)

* [XML Files](https://www.xmlfiles.com/)

* [XML Tutorial](https://www.w3schools.com/xml/default.asp)

* [xml default namespace rage](https://gist.github.com/jennybc/bbe4de369e8d3c9621c2b43949223b3b)

* [Memory Management in the the XML Package](http://www.omegahat.net/RSXML/MemoryManagement.html)

* XML in a Nutshell by Elliotte Rusty Harold; W. Scott Means

* Introduction to Data Technologies by Paul Murrell

* XML and Web Technologies for Data Sciences with R by Deb Nolan and Duncan
  Temple Lang
