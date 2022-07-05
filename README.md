# NCEAS Scientific Computing Support Team Tasks

## Repository Explanation

This is a project-neutral repository for all scripts that don't fit neatly under an existing repository but cannot be written as standalone functions (those miscellaneous functions are part of [`scicomptools`](https://github.com/NCEAS/scicomptools)).

Sometimes working group needs evolve and scripts that we have completed wind up being unnecessary for their projects. However, often those scripts can have unanticipated value to other teams and should be preserved. While it wouldn't make sense to force every project's repo to hold onto those scripts for hypothetical future value, it does make sense to house them in one place where they can easily be found when their time to shine comes around. This repository is that place.

## Navigating the Repository

Given that this repository is meant to be a sort of "grab bag" of unrelated scripts organization is--understandably--an issue. To aid with this, we have adopted the following structure:

- Content for the website is un-filed in the top-level repository folder. This is required for Quarto at this point but will be revised later
-   All scripts are placed in a folder specific to either (A) the working group they were created for or if not applicable (B) their purpose
    -   These folders have the prefix "wg\_" or "misc\_" depending on which of these fits
-   Each of these folders contains its own README.md file that includes a short (1-2 sentence) executive summary of *all* of the scripts in that folder

## Instructions for Contributing

We have developed some guidelines for contributing to this repository while maintaining an easily-navigable organization system. These rules will also help when future Sci Comp staff attempt to decipher this repository and they will thank you for your efforts now!

When you are adding a script, **check to see if an existing folder makes sense to house your script**.

### If there **is** an existing folder:

1.  Put your script in that folder
2.  Add a short (1-2 sentence) description of your script to the README.md file in that folder

### If there **is not** an existing folder:

1.  Create a folder that meets the following criteria:
    -   Prefix of either "misc\_" or "wg\_" depending on whether the script was built for a working group ("wg") or for some other purpose ("misc")
    -   All lowercase
    -   Underscores ("\_") to separate words
2.  Put your script in that folder
3.  Create a README.md in that folder with a short (1-2 sentence) description of your script
    -   See existing folders' READMEs for examples if needed
