workflow test {
    call echo
}

task echo {
    String text
    command {
        echo ${text}
    }
}