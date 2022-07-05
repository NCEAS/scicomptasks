# Scientific Computing Support Quarto Website

## Note on \_quarto.yml

There is a file called "\_quarto.yml" in the main folder of this repository that defines the core formatting of the Sci Comp website. **It must be in the top-level folder for the website to render properly.** However, all of the rest of the website content can be found in this folder (see below for a more complete discussion of those files).

### TLDR: Do *NOT* move the \_quarto.yml file but do put all *other* content in this folder. Thanks!

## File explanation

This folder is somewhat different than the other folders in the repository in that it contains (all but one of) the files that are necessary to build the Sci Comp website.

Each **.qmd** file creates a different page for the website.

The "images" folder contains all of the external images that are embedded into any page of the site.

The *styles.css* file is necessary for rendering a Quarto website.
