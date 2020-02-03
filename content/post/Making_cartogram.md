+++
image = ""
date = "2017-06-01T20:15:43-05:00"
title = "Making a Cartogram with R (and some outside help)"
tags = ['tutorial', 'r', 'visualization']
highlight = true
math = false

+++
![](/img/H1B_Cartogram_files/figure-html/unnamed-chunk-1-1.png)<!-- -->

# #Respect
Much of this tutorial could not have been accomplished without [Frank Hecker's Blog](https://rpubs.com/frankhecker/64539) including a key function to create a dataframe from the shapefiles.

## Some Background
In April, Peter Kahn and Tova Gardin published a [Research Letter in the Journal of the American Medical Association (JAMA)](http://jamanetwork.com/journals/jama/fullarticle/2620160). The article includes a table of number and percent of active physicians holding H1B visas. A few things surprised me in the map.

When I saw the data, I thought it would make an interesting [cartogram](https://www.wikiwand.com/en/Cartogram), a type of map that weighs the geographic area by the data instead of land mass. The result is what you see above.

R has some powerful tools for standard mapping, but drawing a cartogram takes a little more effort and, to make things simpler, an outside program, called [ScapeToad](scapetoad.choros.ch)

## Packages and shape files
The packages I used to prepare the cartogram are the `sp`, `rgdal`, and `dplyr` packages. To get the shapefile for the United States, I just googled around. I had issues with the Census shapefile projection so I used one from [ArcGIS](https://www.arcgis.com/home/item.html?id=f7f805eb65eb4ab787a0a3e1116ca7e5)

I use `rgdal::readOGR` to read the shapefile.



## Sanity checks
I plot the shapefile just to make sure that the projection passes the eye test.  

```r
plot(states.map)
```

![](/img/H1B_Cartogram_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

Next I take a look at the data from the shapefile

```r
str(states.map@data)
```

```
## 'data.frame':	51 obs. of  5 variables:
##  $ STATE_NAME: Factor w/ 51 levels "Alabama","Alaska",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ DRAWSEQ   : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ STATE_FIPS: Factor w/ 51 levels "01","02","04",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ SUB_REGION: Factor w/ 9 levels "East North Central",..: 6 6 4 5 8 8 4 1 4 5 ...
##  $ STATE_ABBR: Factor w/ 51 levels "AK","AL","AR",..: 12 48 27 22 29 42 51 49 14 47 ...
```

Next I read in the data of the H1B visa holders and take a look at the structue

```r
h1b <- read.csv("H1B.csv", stringsAsFactors = F)
str(h1b)
```

```
## 'data.frame':	50 obs. of  5 variables:
##  $ State                         : chr  "New York" "Michigan" "Illinois" "Ohio" ...
##  $ Number.of.Physician.LCAs      : int  1467 945 826 606 602 545 343 309 244 242 ...
##  $ Percent.of.Physician.LCAs     : num  13.98 9.01 7.87 5.78 5.74 ...
##  $ Active.Patient.Care.Physicans : int  58000 23987 30223 28097 34057 23574 51430 90159 13571 10531 ...
##  $ Percent.Patient.Care.Physicans: num  2.5 3.94 2.73 2.16 1.77 2.31 0.67 0.34 1.8 2.3 ...
```

By looking at the structure, I notice that in the `h1b` dataset, the State names are the column "State" while the `states.map` data has the State names under the "STATE_NAME" column. So I change the column names to "NAME" to match one another.


```r
colnames(h1b)[1] <- c("NAME")
names(states.map)[1] <- c("NAME")
```

Next I join the `h1b` data to the `states.map` using `ddplr::left_join`

```r
states.map@data <- states.map@data %>%
  left_join(h1b, by = "NAME")
```

One last sanity check and when that checks out, I write the file to an ESRI shapefile that can be read by ScapeToad

```r
str(states.map@data)
```

```
## 'data.frame':	51 obs. of  9 variables:
##  $ NAME                          : chr  "Hawaii" "Washington" "Montana" "Maine" ...
##  $ DRAWSEQ                       : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ STATE_FIPS                    : Factor w/ 51 levels "01","02","04",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ SUB_REGION                    : Factor w/ 9 levels "East North Central",..: 6 6 4 5 8 8 4 1 4 5 ...
##  $ STATE_ABBR                    : Factor w/ 51 levels "AK","AL","AR",..: 12 48 27 22 29 42 51 49 14 47 ...
##  $ Number.of.Physician.LCAs      : int  NA 189 18 86 75 37 17 184 0 15 ...
##  $ Percent.of.Physician.LCAs     : num  NA 1.8 0.17 0.82 0.71 0.35 0.16 1.75 0 0.14 ...
##  $ Active.Patient.Care.Physicans : int  NA 16884 227 389 162 180 114 13462 0 187 ...
##  $ Percent.Patient.Care.Physicans: num  NA 1.12 0.81 2.22 4.68 2.02 1.54 1.37 0 0.8 ...
```

```r
writeOGR(states.map,
         dsn = ".",
         layer = "states",
         driver = "ESRI Shapefile",
         overwrite_layer = TRUE)
```

Getting ScapeToad to work on my mac took some trial and error and I was only able to get it to work using the JRE. Here are the steps I used to get it to run:

1. [Download ScapeToad.jar](https://scapetoad.choros.ch/download.php)
2. Make sure you have the necessary version of JRE
3. Via the terminal, run `java -Xmx512m -jar wherever/scapetoad.jar/is/located/`. For me this was: `java -Xmx512m -jar ~/Downloads/ScapToad-v11/ScapeToad.jar`

Once ScapeToad opens, it's pretty self explanatory. You upload the shapefile and tell it which variable will be the basis of the cartogram. For a more in-depth explanation of ScapeToad (with images) see [this post](http://gis.yohman.com/blog/2011/11/07/tutorial-building-cartograms/)

Now that we exported the shape file from ScapeToad, it's time to go back to R:


```
## [1] TRUE
```

```
## OGR data source with driver: ESRI Shapefile
## Source: ".", layer: "states_cart"
## with 51 features
## It has 11 fields
## Integer64 fields read as strings:  DRAWSEQ N__P_LC A_P_C_P
```

```
## OGR data source with driver: ESRI Shapefile
## Source: "states_21basic/", layer: "states"
## with 51 features
## It has 5 fields
```

I ran into a problem in the following step with the `convert_map` function so after a bit of googling, I found [this StackOverflow question](https://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true) That had the `if (!require(gpclib)) install.packages("gpclib", type="source")` fix.

I'm always checking what the data looks like so...


```
## 'data.frame':	51 obs. of  11 variables:
##  $ NAME       : Factor w/ 51 levels "Alabama","Alaska",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ DRAWSEQ    : Factor w/ 51 levels "1","10","11",..: 1 12 23 34 45 48 49 50 51 2 ...
##  $ STATE_F    : Factor w/ 51 levels "01","02","04",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ SUB_REG    : Factor w/ 9 levels "East North Central",..: 6 6 4 5 8 8 4 1 4 5 ...
##  $ STATE_A    : Factor w/ 51 levels "AK","AL","AR",..: 12 48 27 22 29 42 51 49 14 47 ...
##  $ N__P_LC    : Factor w/ 46 levels "0","100","106",..: 1 19 17 43 39 30 15 18 1 11 ...
##  $ P__P_LC    : num  0 1.8 0.17 0.82 0.71 0.35 0.16 1.75 0 0.14 ...
##  $ A_P_C_P    : Factor w/ 47 levels "0","10128","10443",..: 1 14 22 32 13 16 5 7 1 17 ...
##  $ P_P_C_P    : num  NaN 1.12 0.81 2.22 4.68 2.02 1.54 1.37 0 0.8 ...
##  $ P__P_LCDens: num  0 0.08674 0.00377 0.08568 0.03246 ...
##  $ SizeError  : num  0 103.4 49.7 97.6 88.7 ...
```

```
## 'data.frame':	51 obs. of  5 variables:
##  $ STATE_NAME: Factor w/ 51 levels "Alabama","Alaska",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ DRAWSEQ   : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ STATE_FIPS: Factor w/ 51 levels "01","02","04",..: 12 48 27 20 35 42 51 50 13 46 ...
##  $ SUB_REGION: Factor w/ 9 levels "East North Central",..: 6 6 4 5 8 8 4 1 4 5 ...
##  $ STATE_ABBR: Factor w/ 51 levels "AK","AL","AR",..: 12 48 27 22 29 42 51 49 14 47 ...
```

I also wanted to make sure the import of the shapefile worked:

![](/img/H1B_Cartogram_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](/img/H1B_Cartogram_files/figure-html/unnamed-chunk-10-2.png)<!-- -->

I was also getting some weird projections because I'm pretty sure my original US shapefule included Minor Outlying Territories.


```
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [15] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [29] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [43] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
```

This is the `convert_map` function I mentioned above. I found this function while trying to figure out how to make a cartogram from [Frank Hecker's Blog](https://rpubs.com/frankhecker/64539) that converts the spacial data into a dataframe.


```r
convert_map <- function(map) {
  temp_map <- map  # Avoid modifying original map in the next step
  temp_map@data$id <- rownames(temp_map@data)
  points <- fortify(temp_map, region = "id")
  df <- full_join(points, temp_map@data, by = "id")
  return(df)
}
```

The rest of my steps really match [Mr. Hecker's steps](https://rpubs.com/frankhecker/64539): I convert both maps to a dataframe. Then I center the labels based on Frank's steps.


```r
unmod_df <- convert_map(states.map)

h1bcg <- gBuffer(h1bcg, byid = TRUE, width = 0)
cg_df <- convert_map(h1bcg)

unmodified_centers = coordinates(states.map)
unmodified_centers_df <- as.data.frame(unmodified_centers)
names(unmodified_centers_df) <- c("long", "lat")
unmodified_centers_df$NAME = as.character(states.map@data$STATE_NAME)

h1bcg_centers = coordinates(h1bcg)
h1bcg_df <- as.data.frame(h1bcg_centers)
names(h1bcg_df) <- c("long", "lat")
h1bcg_df$NAME = as.character(h1bcg@data$NAME)
```

Last is the plotting, which is what we all wanted to do anyway:

* I plot the unmodified state map, outlined in gray.
* Plot the labels for the states in black
* Use `coord_equal()` to force the x and y coordinate scales, avoiding further distortion
* Remove all extraneous plot elements, leaving only the map itself.

```r
g <- ggplot() +
  geom_polygon(data = unmod_df,
               aes(x = long, y = lat, group = group),
               fill = NA,
               colour = "grey") +
  geom_text(data = unmodified_centers_df,
            aes(x = long, y = lat, label = NAME),
            size = 2,
            colour = "black",
            show.legend = FALSE) +
  coord_equal() +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank())
print(g)
```

![](/img/H1B_Cartogram_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

```r
g <- ggplot() +
  geom_polygon(data = cg_df,
               aes(x = long, y = lat, group = group),
               fill = NA,
               colour = "grey") +
  geom_text(data = h1bcg_df,
            aes(x = long, y = lat, label = NAME),
            size = 2,
            colour = "black",
            show.legend = FALSE) +
  coord_equal() +
  ggtitle("Cartogram: Percentage of Practicing Physicians holding H1b visa") +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank())
print(g)
```

![](/img/H1B_Cartogram_files/figure-html/unnamed-chunk-14-2.png)<!-- -->
