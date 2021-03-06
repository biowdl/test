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

import "sample.wdl" as sampleWorkflow
import "tasks/biopet.wdl" as biopet

workflow pipeline {
    Array[File] sampleConfigFiles
    String outputDir

    #  Reading the samples from the sample config files
    call biopet.SampleConfig as samplesConfigs {
        input:
            inputFiles = sampleConfigFiles,
            keyFilePath = "config.keys.tsv"
    }

    # Do the jobs that should be executed per sample.
    # Modify sample.wdl to change what is happening per sample
    scatter (sampleId in read_lines(samplesConfigs.keysFile)) {
        call sampleWorkflow.sample as sample {
            input:
                sampleConfigs = sampleConfigFiles,
                sampleId = sampleId,
                outputDir = outputDir + "/samples/" + sampleId
        }
    }

    call echo {
        input:
            outputPath = outputDir + "/echo.out",
            message = "Hello"
    }

    # Put the jobs that need to be done over the result of all samples
    # below this line.

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
