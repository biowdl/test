# Copyright (c) 2018 Sequencing Analysis Support Core - Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import "readgroup.wdl" as readgroup
import "tasks/biopet.wdl" as biopet

workflow library {
    Array[File] sampleConfigs
    String sampleId
    String libraryId
    String outputDir

    # Get the readgroup configuration
    call biopet.SampleConfig as readgroupConfigs {
        input:
            inputFiles = sampleConfigs,
            sample = sampleId,
            library = libraryId,
            tsvOutputPath = libraryId + ".config.tsv",
            keyFilePath = "config.keys.tsv"
    }

    # The jobs that are done per readgroup.
    # Modify readgroup.wdl to change what is happening per readgroup
    scatter (readgroupId in read_lines(readgroupConfigs.keysFile)) {
        if (readgroupId != "") {
            call readgroup.readgroup as readgroup {
                input:
                    outputDir = outputDir + "/rg_" + readgroupId,
                    sampleConfigs = sampleConfigs,
                    readgroupId = readgroupId,
                    libraryId = libraryId,
                    sampleId = sampleId
            }
        }
    }

    call echo {
        input:
            outputPath = outputDir + "/${sampleId}-${libraryId}.txt",
            message = "${sampleId}-${libraryId}}"
    }

    # Add the jobs that are done per library and over the results of
    # all the readgroups below this line.

    output {

    }
}

task echo {
    String outputPath
    String message

    command {
        set -e -o pipefail
        mkdir -p . ${"$(dirname " + outputPath + ")"}
        echo ${message} > ${outputPath}
    }

    output {
        File outputFile = outputPath
    }
}
