workflow test {
    call echo
}

task echo {
    String text
    String outputDir
    command {
        echo ${text} > ${outputDir}/echo.out
    }

    output {
        File out = "${outputDir}/echo.out"
    }
}