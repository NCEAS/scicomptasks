---
title: "Editing System Metadata"
author: "Jeanette Clark"
date: "5/8/2017"
output: html_document
---

# Introduction
Every object in the Arctic Data Center (or on the KNB) has "system metadata." An object's system metadata has information about the file itself, such as the name of the file, the format, who the rights holder is, and what the access policy is (amongst other things).

Although the majority of system metadata changes that need to be made are done with the functions in arcticdatautils, sometimes we need to change aspects of the system metadata (or sysmeta) outside of those functions. This markdown explains how to do this using the functions `getSystemMetadata` and `updateSystemMetadata`.

# Editing sysmeta

First we need to load in some packages, and set up our environment. Note that typically if you are editing sysmeta you will need to set a token just like if you were updating a package.

```{r setup}
library(arcticdatautils)
library(dataone)

cn <- CNode('STAGING')
mn <- getMNode(cn,'urn:node:mnTestARCTIC') #Loading in the test environment for this example
```

Next, we input the `mn` instance and PID of interest into the `getSystemMetadata` function. Note that the PID should be of the object of interest, not just the package of interest. Each individual object (metadata file, resource map, data file) will have its own system metadata.

```{r getsysmeta, eval=FALSE}
pid <- 'urn:uuid:9a1b02a8-713e-4682-aafb-95c854a4c24a'
sysmeta <- getSystemMetadata(mn, pid)
```

This returns an S4 object, similar to what you have using the EML package, called `sysmeta`. The sysmeta object has the following slots:
serial version, identifier, formatId, size, checksum, checksumAlgorithm, submitter, rightsHolder, accesPolicy, replicationAllowed, numberReplicas, preferredNodes, blockedNodes, obsoletes, obsoletedBy, archived, dateUploaded, dateSysMetaModified. Similar to working with the EML package, you can view and edit slots using `@`. 

`sysmeta@fileName`
`[1] "WELTS_flatfile.csv"`

If you want to change a slot, you can simply do the following:
```{r change slot, eval = FALSE}
sysmeta@fileName <- 'AlaskaWells.csv'
```

Note that some slots cannot be changed by simple text replace (particularly the accessPolicy). There are various helper functions for changing the accessPolicy and rightsHolder such as `addAccessRule` (which takes the sysmeta as an input) or `set_access`, which only requires a PID. In general, you most frequently need to use `getSystemMetadata` to change either the formatId or fileName slots.

After you have changed the necessary slot, you can update the system metadata using the `updateSystemMetadata` function, which takes the `mn` instance, your PID of interest, and the edited sysmeta object as arguments.

```{r getsysmeta, eval=FALSE}
updateSystemMetadata(mn, pid, sysmeta)
```

# Editing sysmeta on lots of files

If you have a lot of files that all need a similar change, you can use a for loop or the apply functions to efficiently make all of your changes. Say you need to change all of the format IDs of data objects in a package so that they are `text/csv`. You could do this:

```{r getsysmeta, eval=FALSE}
PID <- 'some_pid'
ids <- get_package(mn, PID) #get all pids in a package
for (i in 1:length(ids$data)){    #run for loop over all of the data ids
  sysmeta <- getSystemMetadata(mn, pids[i])
  sysmeta@formatId <- "text/csv"
  updateSystemMetadata(mn, pids[i], sysmeta)
}
```

# One last thing...

Importantly, changing the system metadata does NOT necessitate a change in the PID of an object. This is because changes to the system metadata do not change the object itself, they are only changing the description of the object (although ideally the system metadata is accurate when an object is first published). 

