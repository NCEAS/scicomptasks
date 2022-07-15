# Silica Export Working Group Scripts

## Script explanation

**revised-sizer-script.R**

- *(R Script)* Does a more nuanced job (than "silica-SiZer-pkg-exploration.R" of exploring `SiZer` extraction and creation/export of diagnostic ggplots (as well as base plot `Sizer` outputs). `source`s "sizer-helper-fxns.R"

**sizer-helper-fxns.R**

- *(R Script)* Contains several custom functions built to make extracting relevant information from `SiZer::SiZer` outputs easier / simpler

**silica-SiZer-pkg-exploration.R**

- *(R Script)* Explores the Significant Zeros R package (`SiZer`) to identify inflection/break points where the slope of a curved line changes direction

**sizer_script_for_JC.R**

- *(R Script)* A streamlined version of "silica-SiZer-pkg-exploration.R" written specifically for Joanna Carey to explore and stress-test the `sizer_extract` function included in the "sizer-helper-fxns.R" script

**sizer_script_for_JC_v2.R**

- *(R Script)* A streamlined version of "revised-sizer-script.R" written specifically for Joanna Carey to continue to explore / stress-test the new custom functions in "sizer-helper-fxns.R"
